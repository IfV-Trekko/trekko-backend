import 'package:json_annotation/json_annotation.dart';

part 'code_request.g.dart';

@JsonSerializable()
class CodeRequest {
  @JsonKey(name: "code")
  final String code;

  CodeRequest(this.code);

  dynamic toJson() => _$CodeRequestToJson(this);

  factory CodeRequest.fromJson(dynamic json) =>
      _$CodeRequestFromJson(json);
}
