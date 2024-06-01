import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/position_collection.dart';

class WrapperResult<R extends PositionCollection> {
  final R result;
  final Iterable<RawPhoneData> unusedDataPoints;

  WrapperResult(this.result, this.unusedDataPoints);
}