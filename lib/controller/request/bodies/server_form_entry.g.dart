// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_form_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerFormEntry _$ServerFormEntryFromJson(Map<String, dynamic> json) =>
    ServerFormEntry(
      json['key'] as String,
      json['title'] as String,
      json['type'] as String,
      json['required'] as bool,
      (json['options'] as List<dynamic>)
          .map((e) => FormEntryOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ServerFormEntryToJson(ServerFormEntry instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'type': instance.type,
      'required': instance.required,
      'options': instance.options,
    };
