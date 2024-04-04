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

  TripQuery andTimeBetween(DateTime start, DateTime end) {
    filter = filter.and().group((q) => q.legsElement((l) =>
        l.trackedPointsElement((tp) => tp.timestampBetween(start, end))));
    return this;
  }

  Stream<List<Trip>> stream() {
    return build().watch(fireImmediately: true);
  }

  Query<Trip> build() {
    return filter.build();
  }
}
