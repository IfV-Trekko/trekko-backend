import 'package:trekko_backend/controller/wrapper/analyzer/analyzing_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/black_hole_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/data_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/manual/manual_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/manual/simple_position_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/position_filter.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/trip.dart';

enum WrapperType<T extends DataWrapper<Trip>> {
  ANALYZER<DataWrapper<Trip>>(true, buildAnalyzer),
  MANUAL<ManualTripWrapper>(true, buildManual),
  FILTERED_ANALYZER<DataWrapper<Trip>>(true, buildFilteredAnalyzer),
  BLACK_HOLE<DataWrapper<Trip>>(true, buildBlackHole);

  final bool needsRealPositionData;
  final T Function(Iterable<RawPhoneData>) builder;

  const WrapperType(this.needsRealPositionData, this.builder);

  T build(Iterable<RawPhoneData> initial) {
    return builder(initial);
  }
}

DataWrapper<Trip> buildBlackHole(Iterable<RawPhoneData> initial) {
  return BlackHoleWrapper(initial);
}

DataWrapper<Trip> buildFilteredAnalyzer(Iterable<RawPhoneData> initial) {
  return PositionFilter<Trip>(AnalyzingTripWrapper(initial));
}

DataWrapper<Trip> buildAnalyzer(Iterable<RawPhoneData> initial) {
  return AnalyzingTripWrapper(initial);
}

ManualTripWrapper buildManual(Iterable<RawPhoneData> initial) {
  return SimplePositionWrapper(initial);
}
