import 'package:json_annotation/json_annotation.dart';

part 'server_user.g.dart';

@JsonSerializable()
class ServerUser {
  @JsonKey(name: "id")
  final String id;

  @JsonKey(name: "email")
  final String email;

  @JsonKey(name: "emailConfirmed")
  final bool emailConfirmed;

  @JsonKey(name: "profile")
  final Map<String, dynamic>? profile;

  @JsonKey(name: "createdAt")
  final DateTime createdAt;

  @JsonKey(name: "updatedAt")
  final DateTime updatedAt;

  ServerUser(this.id, this.email, this.emailConfirmed, this.profile,
      this.createdAt, this.updatedAt);

  dynamic toJson() => _$ServerUserToJson(this);

  factory ServerUser.fromJson(dynamic json) =>
      _$ServerUserFromJson(json);
}
