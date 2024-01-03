import 'dart:async';

import 'package:app_backend/controller/analysis/cached_analysis_builder.dart';
import 'package:app_backend/controller/analysis/trips_analysis.dart';
import 'package:app_backend/controller/onboarding/onboarder.dart';
import 'package:app_backend/controller/tracking_state.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/wrapper/analyzing_trip_wrapper.dart';
import 'package:app_backend/controller/wrapper/trip_wrapper.dart';
import 'package:app_backend/model/account/profile.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ProfiledTrekko implements Trekko {

  final Profile _profile;
  late TrackingState _trackingState;
  late Isar _isar;
  late StreamController<Position> _positionController;

  ProfiledTrekko(this._profile) {
    _trackingState = TrackingState.paused;
    _positionController = StreamController.broadcast();
  }

  Future<void> init() async {
    await _listenForLocationPermission();
    await _startTracking();

    var dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [TripSchema],
      directory: dir.path,
    );
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
        subscription = Geolocator.getPositionStream().listen((event) {
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
  Profile getProfile() {
    return _profile;
  }

  @override
  Stream<TripsAnalysis> analyze(Query<Trip> query) {
    return CachedAnalysisBuilder().build(query);
  }

  @override
  Future donate(Query<Trip> query) {
    // TODO: implement donate
    throw UnimplementedError();
  }

  @override
  Onboarder getOnboarder() {
    // TODO: implement getOnboarder
    throw UnimplementedError();
  }

  @override
  Future<void> saveTrip(Trip trip) async {
    await _isar.writeTxn(() async {
      await _isar.trips.put(trip);
    });
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

    if (_trackingState == TrackingState.running) {
      LocationPermission permission = await Geolocator.requestPermission();
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
