import 'package:trekko_backend/controller/wrapper/data_wrapper.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

abstract class WrapperStream<R> {

  Stream<R> getResults();

  void add(Iterable<RawPhoneData> data);

  DataWrapper<R> getWrapper();

  bool isProcessing();

}