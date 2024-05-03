import 'package:trekko_backend/model/trip/donation_state.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:isar/isar.dart';

class TripQuery {
  late QueryBuilder<Trip, Trip, QAfterFilterCondition> filter;

  TripQuery(QueryBuilder<Trip, Trip, QWhere> query) {
    filter = query.filter().idGreaterThan(-1);
  }

  // Private constructor for copy
  TripQuery._(QueryBuilder<Trip, Trip, QAfterFilterCondition> this.filter);

  TripQuery andTransportType(TransportType type) {
    return TripQuery._(
        filter.and().legsElement((l) => l.transportTypeEqualTo(type)));
  }

  TripQuery andAnyId(Iterable<int> ids) {
    return TripQuery._(
        filter.and().anyOf(ids, (q, element) => q.idEqualTo(element)));
  }

  TripQuery andId(int id) {
    return TripQuery._(filter.and().idEqualTo(id));
  }

  TripQuery andTimeBetween(DateTime start, DateTime end) {
    return TripQuery._(filter.and().legsElement(
        (q) => q.trackedPointsElement((q) => q.timestampBetween(start, end))));
  }

  TripQuery andDonationState(DonationState state) {
    return TripQuery._(filter.and().donationStateEqualTo(state));
  }

  TripQuery notDonationState(DonationState state) {
    return TripQuery._(filter.and().not().donationStateEqualTo(state));
  }

  TripQuery andTimeAbove(DateTime start) {
    return TripQuery._(filter.and().legsElement(
        (q) => q.trackedPointsElement((q) => q.timestampGreaterThan(start))));
  }

  Future<List<Trip>> collect() {
    return filter.build().findAll();
  }

  Future<Trip?> collectFirst() {
    return filter.build().findFirst();
  }

  Future<int> count() {
    return filter.build().count();
  }

  Future<bool> isEmpty() {
    return filter.build().isEmpty();
  }

  Stream<List<Trip>> stream() {
    return filter.build().watch(fireImmediately: true);
  }

  Stream<List<Trip>> completeStream() {
    var query = filter.build();
    return query
        .watchLazy(fireImmediately: true)
        .map((event) => query.findAllSync());
  }

  Query<Trip> build() {
    return filter.build();
  }
}
