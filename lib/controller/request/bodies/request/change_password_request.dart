import 'package:json_annotation/json_annotation.dart';

part 'change_password_request.g.dart';

@JsonSerializable()
class ChangePasswordRequest {
  @JsonKey(name: "email")
  final String email;
  @JsonKey(name: "newPassword")
  final String newPassword;
  @JsonKey(name: "code")
  final String code;

  ChangePasswordRequest(this.email, this.newPassword, this.code);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);
}
