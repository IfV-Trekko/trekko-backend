import 'package:app_backend/controller/analysis/calculation_reduction.dart';
import 'package:app_backend/controller/analysis/trip_data.dart';

abstract class TripsAnalysis {

  double getData(TripData data, CalculationReduction reduction);

}