import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';

@JsonSerializable()
class ErrorResponse {
  @JsonKey(name: "reasonCode")
  final int reasonCode;
  @JsonKey(name: "reason")
  final String message;

  ErrorResponse(this.reasonCode, this.message);

  dynamic toJson() => _$ErrorResponseToJson(this);

  factory ErrorResponse.fromJson(dynamic json) =>
      _$ErrorResponseFromJson(json);

  @override
  String toString() {
    return "ErrorResponse{reasonCode: $reasonCode, message: $message}";
  }
}
