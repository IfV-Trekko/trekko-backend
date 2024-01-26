class ServerProfile {
  final Map<String, dynamic> data;

  ServerProfile(this.data);

  Map<String, dynamic> toJson() => data;

  factory ServerProfile.fromJson(Map<String, dynamic> json) =>
      ServerProfile(json.cast<String, String>());
}
