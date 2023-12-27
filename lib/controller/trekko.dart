import 'dart:async';

import 'package:app_backend/controller/analysis/trip_analysis.dart';
import 'package:app_backend/controller/database/trip/trip_repository.dart';
import 'package:app_backend/controller/onboarding/onboarder.dart';
import 'package:app_backend/controller/tracking_state.dart';
import 'package:geolocator/geolocator.dart';

abstract class Trekko {

  Onboarder getOnboarder();

  TripRepository getTripRepository();

  Stream<TripAnalysis> analyze(); // TODO: Filter

  Future donate(); // TODO: Filter

  Future<Stream<Position>> getPosition();

  Stream<TrackingState> getTrackingState();

  Future<bool> setTrackingState(TrackingState state);

}