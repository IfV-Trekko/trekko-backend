import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

abstract class Patternizer {

  double hasPattern(Iterable<RawPhoneData> data);

  static Patternizer static(double prob) => _StaticPatternizer(prob);

}

class _StaticPatternizer implements Patternizer {
  final double _prob;

  _StaticPatternizer(this._prob);

  @override
  double hasPattern(Iterable<RawPhoneData> data) => _prob;
}