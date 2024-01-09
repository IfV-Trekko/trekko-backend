import 'package:json_annotation/json_annotation.dart';

part 'code_request.g.dart';

@JsonSerializable()
class CodeRequest {
  final String code;

  CodeRequest(this.code);


  Map<String, dynamic> toJson() => _$CodeRequestToJson(this);

  factory CodeRequest.fromJson(Map<String, dynamic> json) => _$CodeRequestFromJson(json);

}