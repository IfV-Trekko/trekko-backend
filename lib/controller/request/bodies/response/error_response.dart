import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';

@JsonSerializable()
class ErrorResponse {
  @JsonKey(name: "reasonCode")
  final int reasonCode;
  @JsonKey(name: "reason")
  final String message;

  ErrorResponse(this.reasonCode, this.message);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
}
