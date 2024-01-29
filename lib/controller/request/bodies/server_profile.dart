class ServerProfile {
  final Map<String, dynamic> data;

  ServerProfile(this.data);

  dynamic toJson() => data;

  factory ServerProfile.fromJson(dynamic json) =>
      ServerProfile(json.cast<String, String>());
}
