import 'dart:async';

import 'package:app_backend/controller/analysis/trip_analysis.dart';
import 'package:app_backend/controller/database/trip/trip_repository.dart';
import 'package:app_backend/controller/onboarding/onboarder.dart';
import 'package:app_backend/controller/tracking_state.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/model/account/account_data.dart';
import 'package:geolocator/geolocator.dart';

class UserTrekko implements Trekko {
  final AccountData _accountData;
  late TrackingState _trackingState;
  late TripRepository _tripRepository;
  late StreamController<Position> _positionController;

  UserTrekko(this._accountData) {
    _trackingState = TrackingState.paused;
    _tripRepository = TripRepository();
    _positionController = StreamController.broadcast();

    Geolocator.getServiceStatusStream().listen((event) {
      if (event == ServiceStatus.disabled) {
        setTrackingState(TrackingState.paused);
      }
    });

    _startTracking();
  }

  void _startTracking() {
    StreamSubscription? subscription;
    this.getTrackingState().listen((event) {
      if (event == TrackingState.running) {
        subscription = Geolocator.getPositionStream().listen((event) {
          _positionController.add(event);
        });
      } else {
        subscription?.cancel();
      }
    });
  }

  @override
  Stream<TripAnalysis> analyze() {
    // TODO: implement analyze
    throw UnimplementedError();
  }

  @override
  Future donate() {
    // TODO: implement donate
    throw UnimplementedError();
  }

  @override
  Onboarder getOnboarder() {
    // TODO: implement getOnboarder
    throw UnimplementedError();
  }

  @override
  TripRepository getTripRepository() {
    return _tripRepository;
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
