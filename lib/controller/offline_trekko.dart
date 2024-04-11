import 'dart:async';

import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/analysis/calculation.dart';
import 'package:trekko_backend/controller/request/bodies/response/project_metadata_response.dart';
import 'package:trekko_backend/controller/tracking/cached_tracking.dart';
import 'package:trekko_backend/controller/tracking/tracking.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/trekko_state.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
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
        _tripStream = QueuedWrapperStream(() => BufferedFilterTripWrapper());

  Future<int> _saveProfile(Profile profile) {
    return _profileDb.writeTxn(() async => _profileDb.profiles.put(profile));
  }

  Future<void> _initProfile() async {
    var profileQuery = _profileDb.profiles.filter().idEqualTo(_profileId);
    if (profileQuery.isEmptySync()) {
      throw Exception("Profile not found");
    }

    Profile found = profileQuery.findFirstSync()!;
    found.lastLogin = DateTime.now();
    _profileId = await _saveProfile(found);
  }

  Future<void> _initTrackingListener() async {
    _tracking.track().listen((pos) => _tripStream.add(pos));
    _tripStream.getResults().listen((trip) async {
      await saveTrip(trip);
      await _tracking.clearCache();
    });
  }

  @override
  bool isProcessingLocationData() {
    return _tracking.isProcessing() || _tripStream.isProcessing();
  }

  @override
  Future<void> init(int profileId) async {
    _profileId = profileId;
    _profileDb = await Databases.profile.getInstance();
    await _initProfile();
    _tripDb =
        await Databases.trip.getInstance(path: this._profileId.toString());

    Profile profile = (await getProfile().first);
    await _tracking.init(profile.preferences.batteryUsageSetting);
    await _initTrackingListener();
    if (profile.trackingState == TrackingState.running) {
      await _tracking.start(profile.preferences.batteryUsageSetting);
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
  Future<int> donate(Query<Trip> query) async {
    throw Exception("Cannot donate in offline trekko");
  }

  @override
  Future<int> revoke(Query<Trip> query) async {
    throw Exception("Cannot revoke in offline trekko");
  }

  @override
  Future<int> deleteTrip(Query<Trip> trips) async {
    return _tripDb.writeTxn(() => trips.deleteAll());
  }

  @override
  Future<Trip> mergeTrips(Query<Trip> tripsQuery) async {
    final List<Trip> trips = await tripsQuery.findAll();
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
    return mergedTrip;
  }

  @override
  Stream<T?> analyze<T>(Query<Trip> trips, Iterable<T> Function(Trip) tripData,
      Calculation<T> calc) {
    return trips.watch(fireImmediately: true).map((trips) {
      final Iterable<T> toAnalyse = trips.expand(tripData);
      return toAnalyse.isEmpty ? null : calc.calculate(toAnalyse);
    });
  }

  @override
  Future<int> saveTrip(Trip trip) async {
    return _tripDb.writeTxn(() => _tripDb.trips.put(trip));
  }

  @override
  QueryBuilder<Trip, Trip, QWhere> getTripQuery() {
    return _tripDb.trips.where();
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
      if (!await _tracking.start(profile.preferences.batteryUsageSetting)) {
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
  Stream<Position> getPosition() {
    return _tracking.track().where((event) =>
        event.timestamp.difference(DateTime.now()).abs() <
        Duration(seconds: 5));
  }

  @override
  TrekkoState getState() {
    return TrekkoState.offline;
  }

  @override
  Future<void> terminate({keepServiceOpen = false}) async {
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
