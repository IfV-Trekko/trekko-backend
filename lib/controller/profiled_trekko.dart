import 'dart:async';

import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'package:trekko_backend/controller/utils/query_util.dart';
import 'package:trekko_backend/controller/wrapper/buffered_filter_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/queued_wrapper_stream.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_stream.dart';
import 'package:trekko_backend/model/onboarding_text_type.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';
import 'package:trekko_backend/model/profile/onboarding_question.dart';
import 'package:trekko_backend/model/profile/preferences.dart';
import 'package:trekko_backend/model/profile/profile.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:trekko_backend/model/trip/donation_state.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
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
    _tracking.track().listen((event) => _tripStream.add(event));
    _tripStream.getStream().listen((event) async {
      await saveTrip(event);
      await _tracking.clearCache();
    });
  }

  @override
  bool isProcessingLocationData() {
    return _tracking.isProcessing() || _tripStream.isProcessing();
  }

  @override
  Future<void> init() async {
    _profileDb = await Databases.profile.open();
    await _initProfile();
    _tripDb = await Databases.trip.open(path: this._profileId.toString());
    await _tracking.init();
    await _initTrackingListener();

    Profile profile = (await getProfile().first);
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
            QueryUtil(this).buildIdsOr(foundTrips.map((e) => e.id).toList()));
      }
      return _tripDb.writeTxn(() => trips.deleteAll());
    });
  }

  @override
  Future<Trip> mergeTrips(Query<Trip> tripsQuery) async {
    final List<Trip> trips = await tripsQuery.findAll();
    if (trips.isEmpty) throw Exception("No trips to merge");

    final List<TransportType> transportTypes = trips
        .map((t) => t.getTransportTypes())
        .expand((e) => e)
        .toSet()
        .toList();
    final Distance totalDistance = trips
        .map((t) => t.getDistance())
        .reduce((value, element) => value + element);
    final DateTime startTime = trips
        .map((t) => t.getStartTime())
        .reduce((value, element) => value.isBefore(element) ? value : element);
    final DateTime endTime = trips
        .map((t) => t.getEndTime())
        .reduce((value, element) => value.isAfter(element) ? value : element);

    final Trip mergedTrip = new Trip();

    mergedTrip.startTime = startTime;
    mergedTrip.endTime = endTime;
    mergedTrip.setTransportTypes(transportTypes);
    mergedTrip.setDistance(totalDistance);
    mergedTrip.legs = trips.first.legs;

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
      final Iterable<T> toAnalyse =
          trips.where((trip) => // TODO: Fix, this is highly inefficient
              !trip.isModified()).expand(tripData);
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

    if (state == TrackingState.running) {
      PermissionStatus permission = await Permission.locationWhenInUse.status;
      if (permission != PermissionStatus.granted) {
        permission = await Permission.locationWhenInUse.request();
        if (permission != PermissionStatus.granted) {
          return false;
        }
      }
      permission = await Permission.locationAlways.status;
      if (permission != PermissionStatus.granted) {
        permission = await Permission.locationAlways.request();
        if (permission != PermissionStatus.granted) {
          return false;
        }
      }
    }

    Profile profile = await getProfile().first;
    profile.lastTimeTracked = DateTime.now();
    profile.trackingState = state;
    await _saveProfile(profile);

    if (state == TrackingState.running) {
      await _tracking.start(profile.preferences.batteryUsageSetting);
    } else if (state == TrackingState.paused) {
      await _tracking.stop();
    }
    return true;
  }

  @override
  Stream<Position> getPosition() {
    return _tracking.track();
  }

  @override
  Future<void> terminate({keepServiceOpen = false}) async {
    // await _positionController.close();
    await _tracking.clearCache();
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
