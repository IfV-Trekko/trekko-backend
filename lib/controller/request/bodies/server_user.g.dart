// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerUser _$ServerUserFromJson(Map<String, dynamic> json) => ServerUser(
      json['id'] as String,
      json['email'] as String,
      json['emailConfirmed'] as bool,
      json['profile'] as Map<String, dynamic>,
      DateTime.parse(json['createdAt'] as String),
      DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ServerUserToJson(ServerUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'emailConfirmed': instance.emailConfirmed,
      'profile': instance.profile,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
