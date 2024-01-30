import 'dart:async';

import 'package:app_backend/controller/analysis/reductions.dart';
import 'package:app_backend/controller/location_settings.dart';
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
import 'package:app_backend/model/trip/trip.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';

class ProfiledTrekko implements Trekko {
  final String _projectUrl;
  final String _email;
  final String _token;
  late int _profileId;
  late Isar _isar;
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

  Future<int> _saveProfile(Profile profile) {
    return _isar.writeTxn(() async => await _isar.profiles.put(profile));
  }

  Future<void> _initProfile() async {
    List<OnboardingQuestion> questions = (await _server.getForm())
        .fields
        .map((e) => OnboardingQuestion.fromServer(e))
        .toList();

    var profileQuery = _isar.profiles
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

  Future<void> _listenForLocationPermission() async {
    await Geolocator.getServiceStatusStream().listen((event) {
      if (event == ServiceStatus.disabled) {
        setTrackingState(TrackingState.paused);
      }
    });
  }

  Future<void> startTracking() async {
    _positionSubscription = Geolocator.getPositionStream(
            locationSettings: getSettings(
                (await getProfile().first).preferences.batteryUsageSetting))
        .listen((event) {
      _positionController.add(event);
      if (_positionController.isClosed) {
        _positionSubscription?.cancel();
      }
    });
  }

  Future<void> _startTrackingListener() async {
    this.getTrackingState().listen((event) async {
      if (event == TrackingState.running) {
        await startTracking();
      } else {
        _positionSubscription?.cancel();
      }
    });

    TripWrapper tripWrapper = AnalyzingTripWrapper();
    _positionController.stream.listen((event) async {
      double endTripProbability = await tripWrapper.calculateEndProbability();
      if (tripWrapper.collectedDataPoints() > 0 && endTripProbability > 0.9) {
        await saveTrip(await tripWrapper.get());
        tripWrapper = AnalyzingTripWrapper();
      } else {
        await tripWrapper.add(event);
      }
    });
  }

  @override
  Future<void> init() async {
    _isar =
        await DatabaseUtils.establishConnection([TripSchema, ProfileSchema]);
    await _initProfile();
    await _listenForLocationPermission();

    if ((await getProfile().first).trackingState == TrackingState.running) {
      await startTracking();
    }
    await _startTrackingListener();
  }

  Future<void> terminate() async {
    await _positionController.close();
    await _isar.close();
    await _server.close();
  }

  @override
  Stream<Profile> getProfile() {
    return _isar.profiles
        .filter()
        .idEqualTo(_profileId)
        .build()
        .watch(fireImmediately: true)
        .map((event) => event.first);
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
  Future<void> donate(Query<Trip> query) async {
    await query.findAll().then((trips) async {
      if (trips.isEmpty) throw Exception("No trips to donate");

      if (trips
          .any((element) => element.donationState == DonationState.donated))
        throw Exception("Some trips are already donated");

      await _server.donateTrips(TripsRequest.fromTrips(trips));
      trips.forEach((trip) async {
        trip.donationState = DonationState.donated;
        await saveTrip(trip);
      });
    });
  }

  @override
  Future<void> revoke(Query<Trip> query) async {
    await query.findAll().then((trips) async {
      if (trips.isEmpty) throw Exception("No trips to revoke");

      if (trips
          .any((element) => element.donationState != DonationState.donated))
        throw Exception("Some trips aren't donated");

      trips.forEach((trip) async {
        await _server.deleteTrip(trip.id.toString());
        trip.donationState = DonationState.notDonated;
        await saveTrip(trip);
      });
    });
  }

  @override
  Future<int> deleteTrip(Query<Trip> trips) async {
    return _isar.writeTxn(() async {
      return trips.findAll().then((foundTrips) async {
        for (Trip trip in foundTrips) {
          if (trip.donationState == DonationState.donated) {
            // You may want to make this better performing
            await revoke(getTripQuery().idEqualTo(trip.id).build());
          }
        }
        return await trips.deleteAll();
      });
    });
  }

  @override
  Future<Trip> mergeTrips(Query<Trip> trips) async {
    return await trips.findAll().then((toMerge) async {
      if (toMerge.isEmpty) throw Exception("No trips to merge");

      TripWrapper tripWrapper = AnalyzingTripWrapper();
      List<TrackedPoint> points = toMerge
          .map((trip) => trip.legs)
          .expand((leg) => leg)
          .expand((p) => p.trackedPoints)
          .toList();
      points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      for (var point in points) {
        await tripWrapper.add(point.toPosition());
      }
      Trip merged = await tripWrapper.get();
      int mergedTripId = await saveTrip(merged);
      await deleteTrip(trips);
      if (toMerge.any((t) => t.donationState == DonationState.donated)) {
        await donate(getTripQuery().idEqualTo(mergedTripId).build());
      }
      return merged;
    });
  }

  @override
  Stream<T?> analyze<T>(
      Query<Trip> trips, T Function(Trip) tripData, Reduction<T> reduction) {
    return trips.watch(fireImmediately: true).map((trips) {
      return trips.map(tripData).reduce((t0, t1) => reduction.reduce(t0, t1));
    });
  }

  @override
  Future<int> saveTrip(Trip trip) async {
    if (trip.donationState == DonationState.donated) {
      await _server.updateTrip(ServerTrip.fromTrip(trip));
    }
    return _isar.writeTxn(() async => await _isar.trips.put(trip));
  }

  @override
  QueryBuilder<Trip, Trip, QWhere> getTripQuery() {
    return _isar.trips.where();
  }

  @override
  Stream<TrackingState> getTrackingState() {
    return this.getProfile().map((profile) => profile.trackingState).distinct();
  }

  @override
  Future<bool> setTrackingState(TrackingState state) async {
    if (this.getTrackingState().first == state) {
      return true;
    }

    if (state == TrackingState.running) {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always) {
        await Geolocator.openLocationSettings();
        return false;
      }
    }

    Profile profile = await getProfile().first;
    profile.trackingState = state;
    _saveProfile(profile);
    return true;
  }

  @override
  Future<Stream<Position>> getPosition() async {
    // A stream that returns the current position. The stream will not send any data when the tracking state is paused.
    // The moment the tracking state is changed to running, the stream will start sending data.
    // If the tracking state is running, returns the positionstream from the geolocator package.

    return _positionController.stream;
  }
}
