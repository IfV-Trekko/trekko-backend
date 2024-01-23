import 'dart:async';

import 'package:app_backend/controller/analysis/cached_analysis_builder.dart';
import 'package:app_backend/controller/analysis/trips_analysis.dart';
import 'package:app_backend/controller/location_settings.dart';
import 'package:app_backend/controller/request/bodies/request/trips_request.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:app_backend/controller/request/url_trekko_server.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/database_utils.dart';
import 'package:app_backend/controller/wrapper/analyzing_trip_wrapper.dart';
import 'package:app_backend/controller/wrapper/trip_wrapper.dart';
import 'package:app_backend/model/onboarding_text_type.dart';
import 'package:app_backend/model/profile/preferences.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:app_backend/model/tracking_state.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';

class ProfiledTrekko implements Trekko {
  final Profile _profile;
  late TrackingState _trackingState;
  late Isar _isar;
  late StreamController<Position> _positionController;
  late TrekkoServer _server;

  ProfiledTrekko(this._profile) {
    _trackingState = TrackingState.paused;
    _positionController = StreamController.broadcast();
    _server = UrlTrekkoServer.withToken(_profile.projectUrl, _profile.token);
  }

  Future<void> init() async {
    await _listenForLocationPermission();
    await _startTracking();

    _isar = await DatabaseUtils.establishConnection();
    await _isar.writeTxn(() async {
      await _isar.profiles.put(_profile);
    });
  }

  Future<void> _listenForLocationPermission() async {
    await Geolocator.getServiceStatusStream().listen((event) {
      if (event == ServiceStatus.disabled) {
        setTrackingState(TrackingState.paused);
      }
    });
  }

  Future<void> _startTracking() async {
    StreamSubscription? subscription;
    await this.getTrackingState().listen((event) {
      if (event == TrackingState.running) {
        subscription = Geolocator.getPositionStream(
                locationSettings:
                    getSettings(_profile.preferences.batteryUsageSetting))
            .listen((event) {
          _positionController.add(event);
        });
      } else {
        subscription?.cancel();
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
  Stream<Profile> getProfile() {
    return _isar.profiles
        .where()
        .idEqualTo(_profile.id)
        .build()
        .watch(fireImmediately: true)
        .map((event) => event.first);
  }

  @override
  Future<String> loadText(OnboardingTextType type) {
    return Future.value(
        "Matthias bitte implementiere diese Funktion."); // TODO: implement loadText
  }

  @override
  Future<void> savePreferences(Preferences preferences) async {
    this._profile.preferences = preferences;
    return _isar.writeTxn(() async => await _isar.profiles
        .put(this._profile)
        .then((value) async =>
            await _server.updateProfile(this._profile.toServerProfile())));
  }

  @override
  Future<void> donate(Query<Trip> query) async {
    await query.findAll().then((trips) async {
      await _server.donateTrips(TripsRequest.fromTrips(trips));
    });
  }

  @override
  Future<bool> deleteTrip(int tripId) async {
    return _isar.writeTxn(() async {
      return _isar.trips.delete(tripId).then((found) async {
        if (found) {
          await _server.deleteTrip(tripId.toString());
        }
        return found;
      });
    });
  }

  @override
  Future<Trip> mergeTrips(Query<Trip> trips) async {
    return await trips.findAll().then((trips) async {
      TripWrapper tripWrapper = AnalyzingTripWrapper();
      List<TrackedPoint> points = trips
          .map((trip) => trip.legs)
          .expand((leg) => leg)
          .expand((p) => p.trackedPoints)
          .toList();
      points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      for (var point in points) {
        await tripWrapper.add(point.toPosition());
      }
      Trip merged = await tripWrapper.get();
      trips.forEach((trip) async => await deleteTrip(trip.id));
      await saveTrip(merged);
      await donate(_isar.trips.where().idEqualTo(merged.id).build());
      return merged;
    });
  }

  @override
  Stream<TripsAnalysis> analyze(Query<Trip> query) {
    return CachedAnalysisBuilder().build(query);
  }

  @override
  Future<void> saveTrip(Trip trip) async {
    return _isar.writeTxn(() async => await _isar.trips.put(trip));
  }

  @override
  QueryBuilder<Trip, Trip, QWhere> getTripQuery() {
    return _isar.trips.where();
  }

  @override
  Stream<TrackingState> getTrackingState() {
    return Stream.periodic(Duration(milliseconds: 100), (i) => _trackingState)
        .distinct();
  }

  @override
  Future<bool> setTrackingState(TrackingState state) async {
    if (_trackingState == state) {
      return true;
    }

    if (state == TrackingState.running) {
      LocationPermission permission = await Geolocator.requestPermission();
      await Geolocator.openLocationSettings();
      if (permission != LocationPermission.always) {
        return false;
      }
    }

    _trackingState = state;
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
