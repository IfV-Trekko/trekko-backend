import 'package:app_backend/controller/analysis/analysis_builder.dart';
import 'package:app_backend/controller/analysis/calculation_reductor.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:isar/isar.dart';

class CachedAnalysisBuilder implements AnalysisBuilder {

  @override
  Stream<T?> build<T>(
      Query<Trip> trips, T Function(Trip) tripData, Reduction<T> reduction) {
    return trips.watch(fireImmediately: true).map((trips) {
      return trips.fold<T?>(
          trips.isNotEmpty ? tripData(trips.first) : null,
          (previousValue, element) => previousValue != null
              ? reduction.reduce(previousValue, tripData(element))
              : tripData(element));
    });
  }
}
