class EmptyRequest {
  EmptyRequest();

  dynamic toJson() => {};

  factory EmptyRequest.fromJson(dynamic json) {
    return EmptyRequest();
  }
}
