import 'package:app_backend/controller/request/bodies/server_form_entry.dart';
import 'package:json_annotation/json_annotation.dart';

part 'form_response.g.dart';

@JsonSerializable()
class FormResponse {
  @JsonKey(name: "fields")
  final List<ServerFormEntry> fields;

  FormResponse(this.fields);

  dynamic toJson() => _$FormResponseToJson(this);

  factory FormResponse.fromJson(dynamic json) =>
      _$FormResponseFromJson(json);
}
