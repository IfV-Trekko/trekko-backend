import 'package:trekko_backend/controller/wrapper/position_wrapper.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/trip/leg.dart';

abstract class LegWrapper implements PositionWrapper<Leg> {

  Future<Position?> getLegStart();

}
