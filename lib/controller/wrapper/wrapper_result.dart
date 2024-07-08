import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

class WrapperResult<R> {
  final double confidence;
  final R? result;
  final Iterable<RawPhoneData> unusedDataPoints;

  const WrapperResult(this.confidence, this.result, this.unusedDataPoints);
}