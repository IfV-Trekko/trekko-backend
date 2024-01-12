class ServerProfile {
  final Map<String, String> data;

  ServerProfile(this.data);

  Map<String, dynamic> toJson() => data;

  factory ServerProfile.fromJson(Map<String, dynamic> json) =>
      ServerProfile(json.cast<String, String>());
}
