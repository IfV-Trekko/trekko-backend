import 'package:trekko_backend/controller/wrapper/data_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

class PositionFilter<T> implements DataWrapper<T> {
  static const double desiredAccuracyMeters = 50;

  final DataWrapper<T> _internal;

  PositionFilter(this._internal);

  @override
  add(Iterable<RawPhoneData> data) {
    _internal.add(data.where((e) =>
        e.getType() != RawPhoneDataType.position ||
        (e as Position).accuracy <= desiredAccuracyMeters));
  }

  @override
  Future<WrapperResult<T>> get() {
    return _internal.get();
  }

  @override
  Future<Iterable<RawPhoneData>> getAnalysisData() {
    return _internal.getAnalysisData();
  }

  @override
  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json["internal"] = _internal.save();
    return json;
  }

  @override
  void load(Map<String, dynamic> json) {
    _internal.load(json["internal"]);
  }
}
