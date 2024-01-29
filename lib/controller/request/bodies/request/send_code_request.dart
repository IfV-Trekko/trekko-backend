import 'package:json_annotation/json_annotation.dart';

part 'send_code_request.g.dart';

@JsonSerializable()
class SendCodeRequest {
  @JsonKey(name: "email")
  final String email;

  SendCodeRequest(this.email);

  dynamic toJson() => _$SendCodeRequestToJson(this);

  factory SendCodeRequest.fromJson(dynamic json) =>
      _$SendCodeRequestFromJson(json);
}
