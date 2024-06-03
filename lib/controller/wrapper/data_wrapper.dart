import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

abstract class DataWrapper<R> {

  Future add(Iterable<RawPhoneData> data);

  Future<WrapperResult<R>> get();

  Future<Iterable<RawPhoneData>> getAnalysisData();

  Map<String, dynamic> save();

  void load(Map<String, dynamic> json);
}
