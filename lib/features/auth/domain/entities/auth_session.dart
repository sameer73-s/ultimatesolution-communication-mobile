class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAtUtc,
    required this.roles,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAtUtc;
  final List<String> roles;

  bool get isExpired => DateTime.now().toUtc().isAfter(accessTokenExpiresAtUtc);
}
