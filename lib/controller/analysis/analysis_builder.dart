import 'package:app_backend/controller/analysis/calculation_reductor.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:isar/isar.dart';

abstract class AnalysisBuilder {
  Stream<T?> build<T>(
      Query<Trip> trips, T Function(Trip) tripData, Reduction<T> reduction);
}
