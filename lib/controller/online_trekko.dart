import 'dart:async';

import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/analysis/calculation.dart';
import 'package:trekko_backend/controller/offline_trekko.dart';
import 'package:trekko_backend/controller/request/bodies/request/trips_request.dart';
import 'package:trekko_backend/controller/request/bodies/response/project_metadata_response.dart';
import 'package:trekko_backend/controller/request/bodies/server_trip.dart';
import 'package:trekko_backend/controller/request/trekko_server.dart';
import 'package:trekko_backend/controller/request/url_trekko_server.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/trekko_state.dart';
import 'package:trekko_backend/controller/utils/trip_query.dart';
import 'package:trekko_backend/model/onboarding_text_type.dart';
import 'package:trekko_backend/model/profile/onboarding_question.dart';
import 'package:trekko_backend/model/profile/preferences.dart';
import 'package:trekko_backend/model/profile/profile.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:trekko_backend/model/trip/donation_state.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class OnlineTrekko implements Trekko {
  late TrekkoServer _server;
  late Trekko _internal;

  OnlineTrekko() {
    _internal = OfflineTrekko();
  }

  @override
  bool isProcessingLocationData() {
    return _internal.isProcessingLocationData();
  }

  @override
  Future init(int profileId) async {
    await _internal.init(profileId);
    Profile profile = await this.getProfile().first;
    _server = UrlTrekkoServer.withToken(profile.projectUrl, profile.token);

    List<OnboardingQuestion> questions = (await _server.getForm())
        .fields
        .map((e) => OnboardingQuestion.fromServer(e))
        .toList();
    profile.preferences.onboardingQuestions = questions;
    await savePreferences(profile.preferences);
  }

  @override
  Stream<Profile> getProfile() {
    return _internal.getProfile();
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
  Future savePreferences(Preferences preferences) async {
    return await _server
        .updateProfile(preferences.toServerProfile())
        .then((value) => _internal.savePreferences(preferences));
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
      return _internal.deleteTrip(trips);
    });
  }

  @override
  Future<Trip> mergeTrips(Query<Trip> tripsQuery) async {
    final List<Trip> trips = await tripsQuery.findAll();
    Trip mergedTrip = await _internal.mergeTrips(tripsQuery);

    // if any of the merged trips are donated, donate the merged trip
    if (trips.any((t) => t.donationState == DonationState.donated)) {
      await donate(getTripQuery().idEqualTo(mergedTrip.id).build());
    }

    return mergedTrip;
  }

  @override
  Stream<T?> analyze<T>(Query<Trip> trips, Iterable<T> Function(Trip) tripData,
      Calculation<T> calc) {
    return _internal.analyze(trips, tripData, calc);
  }

  @override
  Future<int> saveTrip(Trip trip) async {
    if (trip.donationState == DonationState.donated) {
      await _server.updateTrip(ServerTrip.fromTrip(trip));
    }
    return _internal.saveTrip(trip);
  }

  @override
  QueryBuilder<Trip, Trip, QWhere> getTripQuery() {
    return _internal.getTripQuery();
  }

  @override
  Stream<TrackingState> getTrackingState() {
    return _internal.getTrackingState();
  }

  @override
  Future<bool> setTrackingState(TrackingState state) async {
    return _internal.setTrackingState(state);
  }

  @override
  TrekkoState getState() {
    return TrekkoState.online;
  }

  @override
  Future terminate({keepServiceOpen = false}) async {
    await _internal.terminate(keepServiceOpen: keepServiceOpen);
    if (!keepServiceOpen) {
      await _server.close();
    }
  }

  @override
  Future signOut({bool delete = false}) async {
    if (delete) await _server.deleteAccount();
    await _server.close();
    return _internal.signOut(delete: delete);
  }
}
