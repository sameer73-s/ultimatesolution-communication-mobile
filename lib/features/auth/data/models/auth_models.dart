import '../../domain/entities/auth_session.dart';

final class LoginRequestModel {
  const LoginRequestModel({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

final class RegisterRequestModel {
  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.displayName,
  });

  final String email;
  final String password;
  final String displayName;

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'displayName': displayName,
  };
}

final class RefreshTokenRequestModel {
  const RefreshTokenRequestModel(this.refreshToken);

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

final class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAtUtc,
    required this.roles,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAtUtc;
  final List<String> roles;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiresAtUtc: DateTime.parse(
        json['accessTokenExpiresAtUtc'] as String,
      ),
      roles: [
        for (final role in (json['roles'] as List<dynamic>)) role as String,
      ],
    );
  }

  AuthSession toEntity() => AuthSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    accessTokenExpiresAtUtc: accessTokenExpiresAtUtc,
    roles: roles,
  );
}

final class ApiResponseModel<T> {
  const ApiResponseModel({
    required this.success,
    this.data,
    required this.message,
    required this.errors,
  });

  final bool success;
  final T? data;
  final String message;
  final List<String> errors;
}
