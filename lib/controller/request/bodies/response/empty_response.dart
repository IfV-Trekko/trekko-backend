class EmptyResponse {
  EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) {
    return EmptyResponse();
  }

  Map<String, dynamic> toJson() => {};
}