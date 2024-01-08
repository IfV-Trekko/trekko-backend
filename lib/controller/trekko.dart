import 'dart:async';

import 'package:app_backend/controller/analysis/trips_analysis.dart';
import 'package:app_backend/controller/tracking_state.dart';
import 'package:app_backend/model/account/onboarding/onboarding_text_type.dart';
import 'package:app_backend/model/account/profile.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';

abstract class Trekko {

  Future<void> init();

  Stream<Profile> getProfile();

  Future<void> saveProfile(Profile profile);

  Future<String> loadText(OnboardingTextType type);

  Future<void> saveTrip(Trip trip);

  QueryBuilder<Trip, Trip, QWhere> getTripQuery();

  Stream<TripsAnalysis> analyze(Query<Trip> query);

  Future<void> donate(Query<Trip> query);

  Future<Stream<Position>> getPosition();

  Stream<TrackingState> getTrackingState();

  Future<bool> setTrackingState(TrackingState state);

}