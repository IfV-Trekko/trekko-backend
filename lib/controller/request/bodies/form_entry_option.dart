import 'package:json_annotation/json_annotation.dart';

part 'form_entry_option.g.dart';

@JsonSerializable()
class FormEntryOption {
  @JsonKey(name: "key")
  final String key;
  @JsonKey(name: "title")
  final String title;

  FormEntryOption(this.key, this.title);

  dynamic toJson() => _$FormEntryOptionToJson(this);

  factory FormEntryOption.fromJson(dynamic json) =>
      _$FormEntryOptionFromJson(json);
}
