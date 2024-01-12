class EmptyRequest {
  EmptyRequest();

  Map<String, dynamic> toJson() => {};

  factory EmptyRequest.fromJson(Map<String, dynamic> json) {
    return EmptyRequest();
  }
}
