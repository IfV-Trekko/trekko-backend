import 'package:trekko_backend/controller/wrapper/position_wrapper.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/position_collection.dart';

abstract class WrapperStream<R extends PositionCollection> {

  Stream<R> getResults();

  void add(RawPhoneData data);

  PositionWrapper<R> getWrapper();

  bool isProcessing();

}