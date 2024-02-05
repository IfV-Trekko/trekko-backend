import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:isar/isar.dart';

class QueryUtil {
  final Trekko trekko;
  QueryBuilder<Trip, Trip, QAfterFilterCondition> query;

  QueryUtil(this.trekko)
      : query = trekko.getTripQuery().filter().idLessThan(0);

  QueryUtil idsOr(List<int> ids) {
    if (ids.isEmpty) return this;
    for (int id in ids) {
      query = query.or().idEqualTo(id);
    }
    return this;
  }

  Query<Trip> build() {
    return query.build();
  }
}
