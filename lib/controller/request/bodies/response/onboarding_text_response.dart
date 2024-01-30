import 'package:json_annotation/json_annotation.dart';

part 'onboarding_text_response.g.dart';

@JsonSerializable()
class OnboardingTextResponse {

  @JsonKey(name: "text")
  final String text;

  OnboardingTextResponse(this.text);

  dynamic toJson() => _$OnboardingTextResponseToJson(this);

  factory OnboardingTextResponse.fromJson(dynamic json) => _$OnboardingTextResponseFromJson(json);

}