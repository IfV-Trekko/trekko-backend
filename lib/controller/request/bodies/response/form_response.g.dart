// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormResponse _$FormResponseFromJson(Map<String, dynamic> json) => FormResponse(
      (json['fields'] as List<dynamic>).map(ServerFormEntry.fromJson).toList(),
    );

Map<String, dynamic> _$FormResponseToJson(FormResponse instance) =>
    <String, dynamic>{
      'fields': instance.fields,
    };
