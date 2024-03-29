import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:isar/isar.dart';

class QueryUtil {
  final Trekko trekko;

  QueryUtil(this.trekko);

  Query<Trip> buildTransportType(TransportType type) {
    return trekko.getTripQuery().filter().legsElement((l) => l.transportTypeEqualTo(type)).build();
  }

  Query<Trip> buildIdsOr(List<int> ids) {
    if (ids.isEmpty) return trekko.getTripQuery().filter().idEqualTo(-1).build();
    QueryBuilder<Trip, Trip, QAfterFilterCondition> query = trekko.getTripQuery().filter().idEqualTo(ids.first);
    for (int id in ids) {
      query = query.or().idEqualTo(id);
    }
    return query.build();
  }
}
