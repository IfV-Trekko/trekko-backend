class AuthRequest {

  final String email;
  final String password;

  AuthRequest(this.email, this.password);

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };

  factory AuthRequest.fromJson(Map<String, dynamic> json) {
    return AuthRequest(
      json['email'],
      json['password'],
    );
  }

}