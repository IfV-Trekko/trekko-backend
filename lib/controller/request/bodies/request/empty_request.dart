class EmptyRequest {
  EmptyRequest();

  dynamic toJson() => Map<String, Duration>();

  factory EmptyRequest.fromJson(dynamic json) {
    return EmptyRequest();
  }
}
