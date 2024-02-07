import 'package:json_annotation/json_annotation.dart';

part 'project_metadata_response.g.dart';

@JsonSerializable()
class ProjectMetadataResponse {
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "terms")
  final String terms;

  ProjectMetadataResponse(this.name, this.terms);

  dynamic toJson() => _$ProjectMetadataResponseToJson(this);

  factory ProjectMetadataResponse.fromJson(dynamic json) =>
      _$ProjectMetadataResponseFromJson(json);
}
