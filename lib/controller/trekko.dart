import 'dart:async';

import 'package:app_backend/controller/analysis/trips_analysis.dart';
import 'package:app_backend/controller/onboarding/onboarder.dart';
import 'package:app_backend/controller/tracking_state.dart';
import 'package:app_backend/model/account/profile.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';

abstract class Trekko {

  Future<void> init();

  Profile getProfile();

  Onboarder getOnboarder();

  Future<void> saveTrip(Trip trip);

  QueryBuilder<Trip, Trip, QWhere> getTripQuery();

  Stream<TripsAnalysis> analyze(Query<Trip> query);

  Future<void> donate(Query<Trip> query);

  Future<Stream<Position>> getPosition();

  Stream<TrackingState> getTrackingState();

  Future<bool> setTrackingState(TrackingState state);

}