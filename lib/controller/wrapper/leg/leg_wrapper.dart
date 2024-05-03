import 'package:trekko_backend/controller/wrapper/data_wrapper.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/trip/leg.dart';

abstract class LegWrapper implements DataWrapper<Leg> {

  Future<Position?> getLegStart();

}
