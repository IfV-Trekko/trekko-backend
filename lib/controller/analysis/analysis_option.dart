import 'package:app_backend/controller/analysis/calculation_reduction.dart';
import 'package:app_backend/controller/analysis/trip_data.dart';

class AnalysisOption {
  final TripData tripData;
  final CalculationReduction reduction;

  AnalysisOption(this.tripData, this.reduction);

  @override
  int get hashCode => tripData.hashCode ^ reduction.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnalysisOption &&
        other.tripData == tripData &&
        other.reduction == reduction;
  }
}
