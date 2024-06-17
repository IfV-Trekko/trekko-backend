import 'package:trekko_backend/controller/wrapper/data_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class BlackHoleWrapper implements DataWrapper<Trip> {
  final List<RawPhoneData> _data = [];

  BlackHoleWrapper(Iterable<RawPhoneData> init) {
    _data.addAll(init);
  }

  @override
  add(Iterable<RawPhoneData> data) {
    _data.addAll(data);
  }

  @override
  Future<WrapperResult<Trip>> get() {
    return Future.value(WrapperResult(1, null, []));
  }

  @override
  Future<Iterable<RawPhoneData>> getAnalysisData() {
    return Future.value(_data);
  }

  @override
  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json["data"] = _data.map((e) => e.toJson()).toList();
    return json;
  }

  @override
  void load(Map<String, dynamic> json) {
    List<dynamic> positions = json["data"];
    _data.clear();
    _data.addAll(positions.map((e) => RawPhoneDataType.parseData(e)));
  }
}
