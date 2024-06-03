import 'package:trekko_backend/controller/wrapper/analyzer/analyzing_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/manual/manual_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/manual/simple_position_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/trip_wrapper.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

enum WrapperType<T extends TripWrapper> {
  ANALYZER<TripWrapper>(true, buildAnalyzer),
  MANUAL<ManualTripWrapper>(true, buildManual);

  final bool needsRealPositionData;
  final T Function(Iterable<RawPhoneData>) builder;

  const WrapperType(this.needsRealPositionData, this.builder);

  T build(Iterable<RawPhoneData> initial) {
    return builder(initial);
  }
}

TripWrapper buildAnalyzer(Iterable<RawPhoneData> initial) {
  return AnalyzingTripWrapper(initial);
}

ManualTripWrapper buildManual(Iterable<RawPhoneData> initial) {
  return SimplePositionWrapper(initial);
}
