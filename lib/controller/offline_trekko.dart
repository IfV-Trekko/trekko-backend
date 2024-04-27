import 'dart:async';

import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/analysis/calculation.dart';
import 'package:trekko_backend/controller/request/bodies/response/project_metadata_response.dart';
import 'package:trekko_backend/controller/tracking/cached_tracking.dart';
import 'package:trekko_backend/controller/tracking/tracking.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/trekko_state.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/controller/utils/trip_query.dart';
import 'package:trekko_backend/controller/wrapper/analyzing_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/buffered_filter_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/queued_wrapper_stream.dart';
import 'package:trekko_backend/controller/wrapper/trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_stream.dart';
import 'package:trekko_backend/model/onboarding_text_type.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/profile/preferences.dart';
import 'package:trekko_backend/model/profile/profile.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class OfflineTrekko implements Trekko {
  final Tracking _tracking;
  final WrapperStream<Trip> _tripStream;
  late int _profileId;
  late Isar _profileDb;
  late Isar _tripDb;

  OfflineTrekko()
      : _tracking = CachedTracking(),
        _tripStream =
            QueuedWrapperStream(() => BufferedFilterTripWrapper(), sync: true);

  Future<int> _saveProfile(Profile profile) {
    return _profileDb.writeTxn(() async => _profileDb.profiles.put(profile));
  }

  Future _initProfile() async {
    var profileQuery = _profileDb.profiles.filter().idEqualTo(_profileId);
    if (profileQuery.isEmptySync()) {
      throw Exception("Profile not found");
    }

    Profile found = profileQuery.findFirstSync()!;
    found.lastLogin = DateTime.now();
    _profileId = await _saveProfile(found);
  }

  Future _processPosition(Position pos) async {
    _tripStream.add(pos);
  }

  _initTrackingListener() {
    _tripStream.getResults().listen((trip) async {
      await Logging.info(
          "Saving trip from ${trip.calculateStartTime().toIso8601String()} to ${trip.calculateEndTime().toIso8601String()}");
      await saveTrip(trip);
      await _tracking.clearCache();
    });
  }

  @override
  bool isProcessingLocationData() {
    return _tracking.isProcessing() || _tripStream.isProcessing();
  }

  @override
  Future init(int profileId) async {
    _profileId = profileId;
    _profileDb = await Databases.profile.getInstance();
    await _initProfile();
    _tripDb =
        await Databases.trip.getInstance(path: this._profileId.toString());

    Profile profile = (await getProfile().first);
    await _tracking.init(profile.preferences.batteryUsageSetting);
    _initTrackingListener();
    if (profile.trackingState == TrackingState.running) {
      await _tracking.start(
          profile.preferences.batteryUsageSetting, _processPosition);
    }
  }

  @override
  Stream<Profile> getProfile() {
    return _profileDb.profiles
        .watchObject(this._profileId, fireImmediately: true)
        .map((event) => event!);
  }

  @override
  Future<String> loadText(OnboardingTextType type) {
    throw Exception("Cannot load texts in offline trekko");
  }

  @override
  Future<ProjectMetadataResponse> loadProjectMetadata() async {
    throw Exception("Cannot load project metadata in offline trekko");
  }

  @override
  Future<void> savePreferences(Preferences preferences) async {
    Profile profile = await getProfile().first;
    profile.preferences = preferences;
    await _saveProfile(profile);
  }

  @override
  Future<int> donate(TripQuery query) async {
    throw Exception("Cannot donate in offline trekko");
  }

  @override
  Future<int> revoke(TripQuery query) async {
    throw Exception("Cannot revoke in offline trekko");
  }

  @override
  Future<int> deleteTrip(TripQuery trips) async {
    return _tripDb.writeTxn(() => trips.build().deleteAll());
  }

  @override
  Future<Trip> mergeTrips(TripQuery tripsQuery) async {
    final List<Trip> trips = await tripsQuery.collect();
    if (trips.isEmpty) throw Exception("No trips to merge");

    List<Leg> legsSorted = trips.expand((trip) => trip.legs).toList();
    legsSorted.sort(
        (a, b) => a.calculateStartTime().compareTo(b.calculateStartTime()));

    List<TrackedPoint> positionsInOrder =
        legsSorted.expand((leg) => leg.trackedPoints).toList();
    positionsInOrder.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    TripWrapper wrapper = AnalyzingTripWrapper();
    positionsInOrder.forEach((point) => wrapper.add(point.toPosition()));

    Trip? mergedTrip;
    try {
      mergedTrip = await wrapper.get();
    } catch (e) {}

    if (mergedTrip == null) {
      mergedTrip = Trip.withData(legsSorted);
    }

    await deleteTrip(tripsQuery);
    await saveTrip(mergedTrip);
    return mergedTrip;
  }

  @override
  Stream<T?> analyze<T>(TripQuery trips, Iterable<T> Function(Trip) tripData,
      Calculation<T> calc) {
    return trips.stream().map((trips) {
      final Iterable<T> toAnalyse = trips.expand(tripData);
      return toAnalyse.isEmpty ? null : calc.calculate(toAnalyse);
    });
  }

  @override
  Future<int> saveTrip(Trip trip) async {
    return _tripDb.writeTxn(() => _tripDb.trips.put(trip));
  }

  @override
  TripQuery getTripQuery() {
    return TripQuery(this._tripDb.trips.where());
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

    Profile profile = await getProfile().first;
    if (state == TrackingState.running) {
      if (!await _tracking.start(
          profile.preferences.batteryUsageSetting, _processPosition)) {
        return false;
      }
    } else if (state == TrackingState.paused) {
      await _tracking.stop();
    }

    profile.lastTimeTracked = DateTime.now();
    profile.trackingState = state;
    await _saveProfile(profile);
    return true;
  }

  @override
  TrekkoState getState() {
    return TrekkoState.offline;
  }

  @override
  Future<void> terminate({keepServiceOpen = false}) async {
    if (await isProcessingLocationData()) {
      throw Exception("Cannot terminate while processing location data");
    }

    if (await _tracking.isRunning()) {
      await _tracking.stop();
    }

    // If no deletion is planned, we can just close the databases and the server
    if (!keepServiceOpen) {
      await _profileDb.close();
      await _tripDb.close();
    }
  }

  @override
  Future<void> signOut({bool delete = false}) async {
    // Terminate, delete the profile, trips and server
    await terminate(keepServiceOpen: true);
    await _tracking.clearCache();

    if (delete) {
      await _profileDb.writeTxn(() => _profileDb.profiles.delete(_profileId));
    } else {
      Profile profile = await getProfile().first;
      profile.token = null;
      await _saveProfile(profile);
    }

    await _profileDb.close();
    await _tripDb.close(deleteFromDisk: delete);
  }
}
