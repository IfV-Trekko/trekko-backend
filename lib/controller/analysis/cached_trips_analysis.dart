import 'package:app_backend/controller/analysis/analysis_option.dart';
import 'package:app_backend/controller/analysis/calculation_reduction.dart';
import 'package:app_backend/controller/analysis/trip_data.dart';
import 'package:app_backend/controller/analysis/trips_analysis.dart';

class CachedTripsAnalysis implements TripsAnalysis {
  Map<AnalysisOption, double> _data;

  CachedTripsAnalysis(Map<AnalysisOption, double> data)
      : this._data = Map()..addAll(data);

  @override
  double getData(TripData data, CalculationReduction reduction) {
    AnalysisOption option = AnalysisOption(data, reduction);
    if (!this._data.containsKey(option)) {
      throw Exception("AnalysisOption not found in CachedTripsAnalysis");
    }

    return this._data[option]!;
  }
}
