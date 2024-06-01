import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/transport_type_data_provider.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/transport_type_evaluator.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

class WeightedTransportTypeEvaluator implements TransportTypeEvaluator {
  final TransportTypeDataProvider dataProvider;

  WeightedTransportTypeEvaluator(this.dataProvider);

  @override
  Future<double> evaluate(List<RawPhoneData> leg) {
    return Future.microtask(() async {
      // TODO: Implement weighted evaluation
      return 1;
    });
  }
}
