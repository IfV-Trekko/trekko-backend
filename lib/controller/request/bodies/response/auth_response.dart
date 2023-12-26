class AuthResponse {
  final String token;

  AuthResponse(this.token);

  Map<String, dynamic> toJson() => {
    'token': token,
  };

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      json['token'],
    );
  }
}
