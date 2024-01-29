class EmptyResponse {
  EmptyResponse();

  factory EmptyResponse.fromJson(dynamic json) {
    return EmptyResponse();
  }

  dynamic toJson() => {};
}
