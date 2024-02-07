import 'dart:async';

import 'package:app_backend/controller/analysis/reductions.dart';
import 'package:app_backend/controller/utils/query_util.dart';
import 'package:app_backend/controller/utils/tracking_util.dart';
import 'package:app_backend/controller/request/bodies/request/trips_request.dart';
import 'package:app_backend/controller/request/bodies/server_trip.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:app_backend/controller/request/url_trekko_server.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/database_utils.dart';
import 'package:app_backend/controller/wrapper/analyzing_trip_wrapper.dart';
import 'package:app_backend/controller/wrapper/trip_wrapper.dart';
import 'package:app_backend/model/onboarding_text_type.dart';
import 'package:app_backend/model/profile/battery_usage_setting.dart';
import 'package:app_backend/model/profile/onboarding_question.dart';
import 'package:app_backend/model/profile/preferences.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:app_backend/model/tracking_state.dart';
import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:fling_units/fling_units.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';

class ProfiledTrekko implements Trekko {
  final String _projectUrl;
  final String _email;
  final String _token;
  late int _profileId;
  late Isar _profileDb;
  late Isar _tripDb;
  late StreamController<Position> _positionController;
  late TrekkoServer _server;
  StreamSubscription? _positionSubscription;

  ProfiledTrekko(
      {required String projectUrl,
      required String email,
      required String token})
      : _projectUrl = projectUrl,
        _email = email,
        _token = token {
    _positionController = StreamController.broadcast();
    _server = UrlTrekkoServer.withToken(projectUrl, token);
  }

  Position _toPosition(LocationDto loc) {
    return Position(
        longitude: loc.longitude,
        latitude: loc.latitude,
        timestamp: DateTime.fromMillisecondsSinceEpoch(loc.time.round()),
        accuracy: loc.accuracy,
        altitude: loc.altitude,
        altitudeAccuracy: 0,
        heading: loc.heading,
        headingAccuracy: 0,
        speed: loc.speed,
        speedAccuracy: loc.speedAccuracy);
  }

  Future<int> _saveProfile(Profile profile) {
    return _profileDb.writeTxn(() async => _profileDb.profiles.put(profile));
  }

  Future<void> _initProfile() async {
    List<OnboardingQuestion> questions = (await _server.getForm())
        .fields
        .map((e) => OnboardingQuestion.fromServer(e))
        .toList();

    var profileQuery = _profileDb.profiles
        .filter()
        .projectUrlEqualTo(_projectUrl)
        .and()
        .emailEqualTo(_email);
    if (profileQuery.isEmptySync()) {
      _profileId = await _saveProfile(Profile(
          _projectUrl,
          _email,
          _token,
          DateTime.now(),
          null,
          TrackingState.paused,
          Preferences.withData(List.empty(growable: true),
              BatteryUsageSetting.medium, questions)));
    } else {
      Profile found = profileQuery.findFirstSync()!;
      found.lastLogin = DateTime.now();
      found.token = _token;
      found.preferences.onboardingQuestions = questions;
      _profileId = await _saveProfile(found);
    }
  }

  Future<void> _startTracking() async {
    if (!(await LocationBackgroundTracking.isRunning())) {
      await LocationBackgroundTracking.init(
          // Wont update on preferences change
          (await this.getProfile().first).preferences.batteryUsageSetting);
    }

    TripWrapper tripWrapper = AnalyzingTripWrapper();
    List<Position> toProcess = await LocationBackgroundTracking.readCache()
        .then((value) => value.map((e) => _toPosition(e)).toList());
    _positionSubscription = (await LocationBackgroundTracking.hook())
        .listen((LocationDto loc) async {
      Position detected = _toPosition(loc);
      _positionController.add(detected);

      List<Position> positions = toProcess.toList()..add(detected);
      if (!toProcess.isEmpty) {
        toProcess.clear();
      }

      for (Position position in positions) {
        print("TRACKED $position");
        double endTripProbability = await tripWrapper.calculateEndProbability();
        print("Trip end probability: $endTripProbability");
        if (tripWrapper.collectedDataPoints() > 0 && endTripProbability > 0.9) {
          print("COLLECT");
          await saveTrip(await tripWrapper.get());
          tripWrapper = AnalyzingTripWrapper();
          await LocationBackgroundTracking.clearCache();
        } else {
          print("ADD");
          await tripWrapper.add(position);
        }
      }
    });
  }

  Future<void> _startTrackingListener() async {
    this._profileDb.profiles.watchObject(this._profileId).listen((event) async {
      TrackingState state = event!.trackingState;
      if (state == TrackingState.running) {
        await _startTracking();
      } else {
        _positionSubscription?.cancel();
        LocationBackgroundTracking.shutdown();
      }
    });
  }

  @override
  Future<void> init() async {
    _profileDb = await DatabaseUtils.openProfiles();
    await _initProfile();
    _tripDb = await DatabaseUtils.openTrips(this._profileId);
    if ((await getProfile().first).trackingState == TrackingState.running) {
      await _startTracking();
    }
    await _startTrackingListener();
  }

  Future<void> terminate() async {
    await _positionController.close();
    if (_positionSubscription != null) await _positionSubscription!.cancel();
    if (await LocationBackgroundTracking.isRunning())
      await LocationBackgroundTracking.shutdown();
    await _profileDb.close();
    await _tripDb.close();
    await _server.close();
  }

  @override
  Stream<Profile> getProfile() {
    return _profileDb.profiles
        .watchObject(this._profileId, fireImmediately: true)
        .map((event) => event!);
  }

  @override
  Future<String> loadText(OnboardingTextType type) {
    return _server.getOnboardingText(type.endpoint).then((value) => value.text);
  }

  @override
  Future<void> savePreferences(Preferences preferences) async {
    Profile profile = await getProfile().first;
    profile.preferences = preferences;
    return await _server
        .updateProfile(profile.preferences.toServerProfile())
        .then((value) => _saveProfile(profile));
  }

  @override
  Future<int> donate(Query<Trip> query) async {
    return query.findAll().then((trips) async {
      if (trips.isEmpty) throw Exception("No trips to donate");

      if (trips
          .any((element) => element.donationState == DonationState.donated))
        throw Exception("Some trips are already donated");

      await _server.donateTrips(TripsRequest.fromTrips(trips));
      for (Trip trip in trips) {
        trip.donationState = DonationState.donated;
        await saveTrip(trip);
      }
      return trips.length;
    });
  }

  @override
  Future<int> revoke(Query<Trip> query) async {
    return query.findAll().then((trips) async {
      if (trips.isEmpty) throw Exception("No trips to revoke");

      if (trips
          .any((element) => element.donationState != DonationState.donated))
        throw Exception("Some trips aren't donated");

      for (Trip trip in trips) {
        await _server.deleteTrip(trip.id.toString());
        trip.donationState = DonationState.notDonated;
        await saveTrip(trip);
      }
      return trips.length;
    });
  }

  @override
  Future<int> deleteTrip(Query<Trip> trips) async {
    return trips.findAll().then((foundTrips) async {
      List<Trip> toRevoke = foundTrips
          .where((t) => t.donationState == DonationState.donated)
          .toList();
      if (!toRevoke.isEmpty) {
        await revoke(QueryUtil(this)
            .idsOr(foundTrips.map((e) => e.id).toList())
            .build());
      }
      return _tripDb.writeTxn(() => trips.deleteAll());
    });
  }

  @override
  Future<Trip> mergeTrips(Query<Trip> tripsQuery) async {
    final List<Trip> trips = await tripsQuery.findAll();
    if (trips.isEmpty) throw Exception("No trips to merge");

    final List<TransportType> transportTypes = trips
        .map((t) => t.getTransportTypes())
        .expand((e) => e)
        .toSet()
        .toList();
    final Distance totalDistance = trips
        .map((t) => t.getDistance())
        .reduce((value, element) => value + element);
    final DateTime startTime = trips
        .map((t) => t.getStartTime())
        .reduce((value, element) => value.isBefore(element) ? value : element);
    final DateTime endTime = trips
        .map((t) => t.getEndTime())
        .reduce((value, element) => value.isAfter(element) ? value : element);

    final TripWrapper tripWrapper = AnalyzingTripWrapper();
    final List<TrackedPoint> points = trips
        .map((trip) => trip.legs)
        .expand((leg) => leg)
        .expand((p) => p.trackedPoints)
        .toList();
    for (var point in points) {
      await tripWrapper.add(point.toPosition());
    }

    final Trip mergedTrip = await tripWrapper.get();

    mergedTrip.startTime = startTime;
    mergedTrip.endTime = endTime;
    mergedTrip.setTransportTypes(transportTypes);
    mergedTrip.setDistance(totalDistance);

    if (mergedTrip.legs.isEmpty) {
      mergedTrip.legs = trips.first.legs;
    }

    final int mergedTripId = await saveTrip(mergedTrip);

    await deleteTrip(tripsQuery);

    // if any of the merged trips are donated, donate the merged trip
    if (trips.any((t) => t.donationState == DonationState.donated)) {
      await donate(getTripQuery().idEqualTo(mergedTripId).build());
    }

    return mergedTrip;
  }

  @override
  Stream<T?> analyze<T>(
      Query<Trip> trips, T Function(Trip) tripData, Reduction<T> reduction) {
    return trips.watch(fireImmediately: true).map((trips) {
      if (trips.isEmpty) return null;
      return trips.map(tripData).reduce((t0, t1) => reduction.reduce(t0, t1));
    });
  }

  @override
  Future<int> saveTrip(Trip trip) async {
    if (trip.donationState == DonationState.donated) {
      await _server.updateTrip(ServerTrip.fromTrip(trip));
    }
    return _tripDb.writeTxn(() => _tripDb.trips.put(trip));
  }

  @override
  QueryBuilder<Trip, Trip, QWhere> getTripQuery() {
    return _tripDb.trips.where();
  }

  @override
  Stream<TrackingState> getTrackingState() {
    return this.getProfile().map((event) => event.trackingState);
  }

  @override
  Future<bool> setTrackingState(TrackingState state) async {
    if (await this.getTrackingState().first == state) {
      return false;
    }

    if (state == TrackingState.running) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always) {
        permission = await Geolocator.requestPermission();
        await Geolocator.openLocationSettings();
        permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.always) {
          return false;
        }
      }
    }

    Profile profile = await getProfile().first;
    profile.lastTimeTracked = DateTime.now();
    profile.trackingState = state;
    _saveProfile(profile);
    return true;
  }

  @override
  Stream<Position> getPosition() {
    // A stream that returns the current position. The stream will not send any data when the tracking state is paused.
    // The moment the tracking state is changed to running, the stream will start sending data.
    // If the tracking state is running, returns the positionstream from the geolocator package.

    return _positionController.stream;
  }
}
