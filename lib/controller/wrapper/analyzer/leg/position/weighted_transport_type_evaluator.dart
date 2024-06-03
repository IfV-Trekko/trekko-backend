import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/transport_type_data.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/transport_type_evaluator.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

class WeightedTransportTypeEvaluator implements TransportTypeEvaluator {
  List<RawPhoneData> _data;

  WeightedTransportTypeEvaluator(this._data);

  @override
  Future add(Iterable<RawPhoneData> data) async {
    _data.addAll(data);
  }

  @override
  Future<WrapperResult<Map<DateTime, TransportTypeData>>> get() {
    // TODO: implement get, so that it returns the result of the evaluation
    throw UnimplementedError();
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
