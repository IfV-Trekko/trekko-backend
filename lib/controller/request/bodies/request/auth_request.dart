import 'package:json_annotation/json_annotation.dart';

part 'auth_request.g.dart';

@JsonSerializable()
class AuthRequest {

  @JsonKey(name: "email")
  final String email;
  @JsonKey(name: "password")
  final String password;

  AuthRequest(this.email, this.password);

  Map<String, dynamic> toJson() => _$AuthRequestToJson(this);

  factory AuthRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthRequestFromJson(json);
}
