import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';

abstract class RawPhoneData {

  RawPhoneDataType getType();

  DateTime getTimestamp();

  Map<String, dynamic> toJson();

}
