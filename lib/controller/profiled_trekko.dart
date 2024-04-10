import 'dart:async';

import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/analysis/calculation.dart';
import 'package:trekko_backend/controller/request/bodies/request/trips_request.dart';
import 'package:trekko_backend/controller/request/bodies/response/project_metadata_response.dart';
import 'package:trekko_backend/controller/request/bodies/server_trip.dart';
import 'package:trekko_backend/controller/request/trekko_server.dart';
import 'package:trekko_backend/controller/request/url_trekko_server.dart';
import 'package:trekko_backend/controller/tracking/cached_tracking.dart';
import 'package:trekko_backend/controller/tracking/tracking.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/trip_query.dart';
import 'package:trekko_backend/controller/wrapper/analyzing_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/buffered_filter_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/queued_wrapper_stream.dart';
import 'package:trekko_backend/controller/wrapper/trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_stream.dart';
import 'package:trekko_backend/model/onboarding_text_type.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';
import 'package:trekko_backend/model/profile/onboarding_question.dart';
import 'package:trekko_backend/model/profile/preferences.dart';
import 'package:trekko_backend/model/profile/profile.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:trekko_backend/model/trip/donation_state.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class ProfiledTrekko implements Trekko {
  final String _projectUrl;
  final String _email;
  final String _token;
  final Tracking _tracking;
  late int _profileId;
  late Isar _profileDb;
  late Isar _tripDb;
  late TrekkoServer _server;
  late WrapperStream<Trip> _tripStream;

  ProfiledTrekko(
      {required String projectUrl,
      required String email,
      required String token})
      : _projectUrl = projectUrl,
        _email = email,
        _token = token,
        _tracking = CachedTracking(),
        _tripStream = QueuedWrapperStream(() => BufferedFilterTripWrapper()) {
    _server = UrlTrekkoServer.withToken(projectUrl, token);
  }

  Future<int> _saveProfile(Profile profile) {
    return _profileDb.writeTxn(() async => _profileDb.profiles.put(profile));
  }

  Future<void> _initProfile() async {
    List<OnboardingQuestion> questions = (await _server.getForm())
        .fields
        .map((e) => OnboardingQuestion.fromServer(e))
        .toList();

    var profileQuery = _profileDb.profiles
        .filter()
        .projectUrlEqualTo(_projectUrl)
        .and()
        .emailEqualTo(_email);
    if (profileQuery.isEmptySync()) {
      _profileId = await _saveProfile(Profile(
          _projectUrl,
          _email,
          _token,
          DateTime.now(),
          null,
          TrackingState.paused,
          Preferences.withData(List.empty(growable: true),
              BatteryUsageSetting.medium, questions)));
    } else {
      Profile found = profileQuery.findFirstSync()!;
      found.lastLogin = DateTime.now();
      found.token = _token;
      found.preferences.onboardingQuestions = questions;
      _profileId = await _saveProfile(found);
    }
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
  Future<void> init() async {
    _profileDb = await Databases.profile.getInstance();
    await _initProfile();
    _tripDb = await Databases.trip.getInstance(path: this._profileId.toString());

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
    return _server.getOnboardingText(type.endpoint).then((value) => value.text);
  }

  @override
  Future<ProjectMetadataResponse> loadProjectMetadata() async {
    final ProjectMetadataResponse? metadata =
        await _server.getProjectMetadata();
    if (metadata == null) throw Exception("Could not load project metadata");

    return metadata;
  }

  @override
  Future<void> savePreferences(Preferences preferences) async {
    Profile profile = await getProfile().first;
    profile.preferences = preferences;
    return await _server
        .updateProfile(profile.preferences.toServerProfile())
        .then((value) => _saveProfile(profile));
  }

  @override
  Future<int> donate(Query<Trip> query) async {
    return query.findAll().then((trips) async {
      if (trips.isEmpty) throw Exception("No trips to donate");

      if (trips
          .any((element) => element.donationState == DonationState.donated))
        throw Exception("Some trips are already donated");

      await _server.donateTrips(TripsRequest.fromTrips(trips));
      for (Trip trip in trips) {
        trip.donationState = DonationState.donated;
        await saveTrip(trip);
      }
      return trips.length;
    });
  }

  @override
  Future<int> revoke(Query<Trip> query) async {
    return query.findAll().then((trips) async {
      if (trips.isEmpty) throw Exception("No trips to revoke");

      for (Trip trip in trips) {
        if (trip.donationState == DonationState.donated) {
          await _server.deleteTrip(trip.id.toString());
        }
        trip.donationState = DonationState.notDonated;
        await saveTrip(trip);
      }
      return trips.length;
    });
  }

  @override
  Future<int> deleteTrip(Query<Trip> trips) async {
    return trips.findAll().then((foundTrips) async {
      List<Trip> toRevoke = foundTrips
          .where((t) => t.donationState == DonationState.donated)
          .toList();
      if (!toRevoke.isEmpty) {
        await revoke(
            TripQuery(this).andAnyId(foundTrips.map((e) => e.id)).build());
      }
      return _tripDb.writeTxn(() => trips.deleteAll());
    });
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

    final int mergedTripId = await saveTrip(mergedTrip);

    // if any of the merged trips are donated, donate the merged trip
    if (trips.any((t) => t.donationState == DonationState.donated)) {
      await donate(getTripQuery().idEqualTo(mergedTripId).build());
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
    if (trip.donationState == DonationState.donated) {
      await _server.updateTrip(ServerTrip.fromTrip(trip));
    }
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
  Future<void> terminate({keepServiceOpen = false}) async {
    if (await _tracking.isRunning()) {
      await _tracking.stop();
    }

    // If no deletion is planned, we can just close the databases and the server
    if (!keepServiceOpen) {
      await Future.wait([_profileDb.close(), _tripDb.close(), _server.close()]);
    }
  }

  @override
  Future<void> signOut({bool delete = false}) async {
    // Terminate, delete the profile, trips and server
    await terminate(keepServiceOpen: true);
    await _tracking.clearCache();

    if (delete) await _server.deleteAccount();
    await _server.close();

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
