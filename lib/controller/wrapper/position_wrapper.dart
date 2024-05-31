import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/position_collection.dart';

abstract class PositionWrapper<R extends PositionCollection> {
  Future<double> calculateEndProbability();

  Future add(RawPhoneData position);

  Future<WrapperResult<R>> get({bool preliminary = false}); //todo: return object that also cotains data points

  Map<String, dynamic> save();

  void load(Map<String, dynamic> json);
}
