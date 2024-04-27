import 'dart:async';

import 'package:trekko_backend/controller/analysis/calculation.dart';
import 'package:trekko_backend/controller/request/bodies/response/project_metadata_response.dart';
import 'package:trekko_backend/controller/trekko_state.dart';
import 'package:trekko_backend/model/onboarding_text_type.dart';
import 'package:trekko_backend/model/profile/preferences.dart';
import 'package:trekko_backend/model/profile/profile.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:isar/isar.dart';

abstract class Trekko {
  /// Initializes the Trekko instance.
  Future init(int profileId);

  /// Returns a stream of the current profile.
  Stream<Profile> getProfile();

  /// Saves the preferences. Also synchronizes the preferences with the server.
  Future savePreferences(Preferences preferences);

  /// Loads a onboarding tex from the server
  Future<String> loadText(OnboardingTextType type);

  Future<ProjectMetadataResponse> loadProjectMetadata();

  /// Saves a trip. Also synchronizes the trip with the server.
  Future<int> saveTrip(Trip trip);

  /// Deletes trips. Also synchronizes the deletion with the server.
  Future<int> deleteTrip(Query<Trip> trips);

  /// Merge multiple trips into one. Also synchronizes the merge with the server.
  Future<Trip> mergeTrips(Query<Trip> trips);

  /// Returns a query builder for trips.
  QueryBuilder<Trip, Trip, QWhere> getTripQuery();

  /// Analyzes a query of trips.
  Stream<T?> analyze<T>(
      Query<Trip> trips, Iterable<T> Function(Trip) tripData, Calculation<T> calc);

  /// Donates a query of trips to the server.
  Future<int> donate(Query<Trip> query);

  /// Revokes a query of trips from the server.
  Future<int> revoke(Query<Trip> query);

  /// Returns whether the tracking is currently processing data.
  bool isProcessingLocationData();

  /// Returns a stream of the current tracking state.
  Stream<TrackingState> getTrackingState();

  /// Sets the tracking state.
  Future<bool> setTrackingState(TrackingState state);

  /// Returns the current state of the Trekko instance.
  TrekkoState getState();

  /// Terminates the Trekko instance
  Future terminate({keepServiceOpen = false});

  /// Logs out the user.
  Future signOut({bool delete = false});
}
