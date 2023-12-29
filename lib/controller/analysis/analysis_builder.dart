import 'package:app_backend/controller/analysis/trips_analysis.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:isar/isar.dart';

abstract class AnalysisBuilder {

  Stream<TripsAnalysis> build(Query<Trip> trips);

}