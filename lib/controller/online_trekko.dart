import 'dart:async';

import 'package:trekko_backend/controller/analysis/calculation.dart';
import 'package:trekko_backend/controller/offline_trekko.dart';
import 'package:trekko_backend/controller/request/bodies/request/trips_request.dart';
import 'package:trekko_backend/controller/request/bodies/response/project_metadata_response.dart';
import 'package:trekko_backend/controller/request/bodies/response/trips_response.dart';
import 'package:trekko_backend/controller/request/bodies/server_trip.dart';
import 'package:trekko_backend/controller/request/trekko_server.dart';
import 'package:trekko_backend/controller/request/url_trekko_server.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/trekko_state.dart';
import 'package:trekko_backend/controller/utils/trip_query.dart';
import 'package:trekko_backend/controller/wrapper/data_wrapper.dart';
import 'package:trekko_backend/model/tracking/analyzer/wrapper_type.dart';
import 'package:trekko_backend/model/onboarding_text_type.dart';
import 'package:trekko_backend/model/profile/onboarding_question.dart';
import 'package:trekko_backend/model/profile/preferences.dart';
import 'package:trekko_backend/model/profile/profile.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:trekko_backend/model/trip/donation_state.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class OnlineTrekko implements Trekko {
  late TrekkoServer _server;
  late Trekko _internal;

  OnlineTrekko() {
    _internal = OfflineTrekko();
  }

  Future<int> _revoke(Iterable<Trip> revoke) async {
    int revoked = 0;
    for (Trip trip in revoke) {
      if (trip.donationState != DonationState.donated) {
        throw Exception("Trip is not donated");
      }
      await _server.deleteTrip(trip.id.toString());
      trip.donationState = DonationState.notDonated;
      await this._internal.saveTrip(trip);
      revoked++;
    }
    return revoked;
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
  Future<int> export(TripQuery query) {
    return _internal.export(query);
  }

  @override
  Future<List<int>> import() {
    return _internal.import();
  }

  @override
  Future<int> donate(TripQuery query) async {
    List<Trip> donate =
        await query.notDonationState(DonationState.donated).collect();
    if (donate.isEmpty) throw Exception("No trips to donate");

    TripsResponse res =
        await _server.donateTrips(TripsRequest.fromTrips(donate));
    Set<int> idsDonated = res.trips.map((e) => int.parse(e.uid)).toSet();
    for (Trip trip
        in donate.where((element) => idsDonated.contains(element.id))) {
      trip.donationState = DonationState.donated;
      await this._internal.saveTrip(trip);
    }
    return res.trips.length;
  }

  @override
  Future<int> revoke(TripQuery query) async {
    List<Trip> revoke =
        await query.andDonationState(DonationState.donated).collect();
    if (revoke.isEmpty) throw Exception("No trips to revoke");
    await _revoke(revoke);
    return revoke.length;
  }

  @override
  Future<int> deleteTrip(TripQuery trips) async {
    TripQuery donated = await trips.andDonationState(DonationState.donated);
    if (!await donated.isEmpty()) {
      await this.revoke(donated);
    }
    return _internal.deleteTrip(trips);
  }

  @override
  Future<Trip> mergeTrips(TripQuery tripsQuery) async {
    Trip mergedTrip = await _internal.mergeTrips(tripsQuery);

    // if any of the merged trips are donated, donate the merged trip
    if (!await tripsQuery.andDonationState(DonationState.donated).isEmpty()) {
      await donate(getTripQuery().andId(mergedTrip.id));
    }

    return mergedTrip;
  }

  @override
  Stream<T?> analyze<T>(TripQuery trips, Iterable<T> Function(Trip) tripData,
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
  TripQuery getTripQuery() {
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

  @override
  Stream<T>? getWrapper<T extends DataWrapper<Trip>>(WrapperType<T> type) {
    return _internal.getWrapper(type);
  }

  @override
  Future sendData(RawPhoneData data, Iterable<WrapperType> types) {
    return _internal.sendData(data, types);
  }
}
