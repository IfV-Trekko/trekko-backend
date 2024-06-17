import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/position/patternizer.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';

abstract class TransportTypeDataProvider {
  DerivedMeasurement<Measurement<Distance>, Measurement<Time>>
      getAverageSpeed();

  Time getMaximumStopTime();

  Patternizer getPatternizer();

  TransportType? getTransportType();
}
