import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/position_collection.dart';

class WrapperResult<R extends PositionCollection> {
  final R result;
  final List<RawPhoneData> unusedDataPoints;

  WrapperResult(this.result, this.unusedDataPoints);

  R getResult() {
    return result;
  }

  List<RawPhoneData> getUnusedDataPoints() {
    return unusedDataPoints;
  }
}