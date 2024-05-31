import 'package:trekko_backend/controller/wrapper/analyzer/buffered_filter_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/manual/manual_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/manual/simple_position_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/trip_wrapper.dart';

enum WrapperType<T extends TripWrapper> {
  ANALYZER<BufferedFilterTripWrapper>(true, buildAnalyzer),
  MANUAL<ManualTripWrapper>(true, buildManual);

  final bool needsRealPositionData;
  final T Function() builder;

  const WrapperType(this.needsRealPositionData, this.builder);

  T build() {
    return builder();
  }
}

BufferedFilterTripWrapper buildAnalyzer() {
  return BufferedFilterTripWrapper();
}

ManualTripWrapper buildManual() {
  return SimplePositionWrapper();
}
