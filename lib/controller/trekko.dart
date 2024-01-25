import 'dart:async';

import 'package:app_backend/controller/analysis/calculation_reductor.dart';
import 'package:app_backend/model/onboarding_text_type.dart';
import 'package:app_backend/model/profile/preferences.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:app_backend/model/tracking_state.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';

abstract class Trekko {
  Future<void> init();

  Stream<Profile> getProfile();

  Future<void> savePreferences(Preferences preferences);

  Future<String> loadText(OnboardingTextType type);

  Future<void> saveTrip(Trip trip);

  Future<bool> deleteTrip(int tripId);

  Future<Trip> mergeTrips(Query<Trip> trips);

  QueryBuilder<Trip, Trip, QWhere> getTripQuery();

  Stream<T?> analyze<T>(
      Query<Trip> trips, T Function(Trip) tripData, Reduction<T> reduction);

  Future<void> donate(Query<Trip> query);

  Future<Stream<Position>> getPosition();

  Stream<TrackingState> getTrackingState();

  Future<bool> setTrackingState(TrackingState state);
}
