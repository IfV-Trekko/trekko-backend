import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:isar/isar.dart';

class TripQuery {
  final Trekko trekko;
  late QueryBuilder<Trip, Trip, QAfterFilterCondition> filter;

  TripQuery(this.trekko) {
    filter = trekko.getTripQuery().filter().idGreaterThan(0);
  }

  TripQuery andTransportType(TransportType type) {
    filter = filter.and().legsElement((l) => l.transportTypeEqualTo(type));
    return this;
  }

  TripQuery andAnyId(Iterable<int> ids) {
    if (ids.isEmpty) {
      filter = filter.and().idEqualTo(-1);
    } else {
      this.filter.and().anyOf(ids, (q, element) => q.idEqualTo(element));
    }
    return this;
  }

  TripQuery andTimeBetween(DateTime start, DateTime end) {
    filter = filter.group((q) => q
        .startTimeGreaterThan(start, include: true)
        .and()
        .endTimeLessThan(end, include: true));
    return this;
  }

  Query<Trip> build() {
    return filter.build();
  }
}
