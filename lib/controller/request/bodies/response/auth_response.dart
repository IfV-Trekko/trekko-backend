import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {

  @JsonKey(name: "token")
  final String token;

  AuthResponse(this.token);

  dynamic toJson() => _$AuthResponseToJson(this);

  factory AuthResponse.fromJson(dynamic json) =>
      _$AuthResponseFromJson(json);
}
