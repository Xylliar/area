class AcessToken {
  String access_token;
  String token_type;

  AcessToken({required this.access_token, required this.token_type});

  factory AcessToken.fromJson(Map<String, dynamic> json) {
    return AcessToken(
      access_token: json['access_token'],
      token_type: json['token_type'],
    );
  }
}