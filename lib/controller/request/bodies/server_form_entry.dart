import 'package:app_backend/controller/request/bodies/form_entry_option.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_form_entry.g.dart';

@JsonSerializable()
class ServerFormEntry {
  final String key;
  final String title;
  final String type;
  final bool required;
  final String? regex;
  final List<FormEntryOption>? options;

  ServerFormEntry(
      this.key, this.title, this.type, this.required, this.regex, this.options);

  Map<String, dynamic> toJson() => _$ServerFormEntryToJson(this);

  factory ServerFormEntry.fromJson(Map<String, dynamic> json) =>
      _$ServerFormEntryFromJson(json);
}
