import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:isar/isar.dart';

class TripQuery {
  final Trekko trekko;
  late QueryBuilder<Trip, Trip, QAfterFilterCondition> filter;

  TripQuery(this.trekko) {
    filter = trekko.getTripQuery().filter().idGreaterThan(-1);
  }

  TripQuery andTransportType(TransportType type) {
    filter = filter.and().legsElement((l) => l.transportTypeEqualTo(type));
    return this;
  }

  TripQuery andAnyId(Iterable<int> ids) {
    filter = filter.and().anyOf(ids, (q, element) => q.idEqualTo(element));
    return this;
  }

  TripQuery andId(int id) {
    filter = filter.and().idEqualTo(id);
    return this;
  }

  TripQuery andTimeBetween(DateTime start, DateTime end) {
    filter = filter.and().legsElement(
        (q) => q.trackedPointsElement((q) => q.timestampBetween(start, end)));
    return this;
  }

  TripQuery andTimeAbove(DateTime start) {
    filter = filter.and().legsElement(
        (q) => q.trackedPointsElement((q) => q.timestampGreaterThan(start)));
    return this;
  }

  QueryBuilder<Trip, Trip, QAfterFilterCondition> get() {
    return filter;
  }

  Stream<List<Trip>> stream() {
    return build().watch(fireImmediately: true);
  }

  Query<Trip> build() {
    return filter.build();
  }
}
