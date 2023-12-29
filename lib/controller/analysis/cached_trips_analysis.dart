import 'package:app_backend/controller/analysis/analysis_option.dart';
import 'package:app_backend/controller/analysis/trips_analysis.dart';

class CachedTripsAnalysis implements TripsAnalysis {

  Map<AnalysisOption, double> _data;

  CachedTripsAnalysis(this._data);

  @override
  double getData(AnalysisOption option) {
    if (!this._data.containsKey(option)) {
      throw Exception("AnalysisOption not found in CachedTripsAnalysis");
    }

    return this._data[option]!;
  }

}