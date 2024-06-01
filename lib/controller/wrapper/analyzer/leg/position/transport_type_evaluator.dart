import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

abstract class TransportTypeEvaluator {
  Future<double> evaluate(List<RawPhoneData> data);
}
