import 'package:app_backend/controller/analysis/analysis_builder.dart';
import 'package:app_backend/controller/analysis/analysis_option.dart';
import 'package:app_backend/controller/analysis/cached_trips_analysis.dart';
import 'package:app_backend/controller/analysis/calculation_reduction.dart';
import 'package:app_backend/controller/analysis/trip_data.dart';
import 'package:app_backend/controller/analysis/trips_analysis.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:isar/isar.dart';

class CachedAnalysisBuilder implements AnalysisBuilder {
  @override
  Stream<TripsAnalysis> build(Query<Trip> trips) {
    return trips.watch().map((trips) {
      Map<AnalysisOption, double> data = {};
      for (var tripData in TripData.values) {
        for (var calc in CalculationReduction.values) {
          var option = AnalysisOption(tripData, calc);
          double calculated = 0;
          for (int i = 0; i < trips.length; i++) {
            var trip = trips[i];
            if (i == 0) {
              calculated = option.tripData.apply(trip);
              continue;
            }

            calculated =
                option.reduction.apply(calculated, option.tripData.apply(trip));
          }
          data[option] = calculated;
        }
      }
      return CachedTripsAnalysis(data);
    });
  }
}
