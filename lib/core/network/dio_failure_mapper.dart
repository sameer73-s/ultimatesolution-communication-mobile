import 'package:dio/dio.dart';

import '../errors/failures.dart';

Failure mapDioError(Object error) {
  if (error is! DioException) {
    return const UnknownFailure();
  }

  final statusCode = error.response?.statusCode;
  final responseMessage = _responseMessage(error.response?.data);

  if (statusCode == null) {
    return NetworkFailure(error.message ?? 'Unable to reach the server.');
  }

  return switch (statusCode) {
    401 => UnauthorizedFailure(responseMessage ?? 'Your session has expired.'),
    403 => ForbiddenFailure(
      responseMessage ?? 'You are not allowed to perform this action.',
    ),
    >= 400 && < 500 => ApiFailure(
      responseMessage ?? 'The request was rejected.',
      statusCode: statusCode,
    ),
    >= 500 => ApiFailure(
      responseMessage ?? 'The server is unavailable.',
      statusCode: statusCode,
    ),
    _ => NetworkFailure(
      error.message ?? 'Unable to reach the server.',
      statusCode: statusCode,
    ),
  };
}

String? _responseMessage(Object? data) {
  if (data case final Map<String, dynamic> body) {
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
  }
  return null;
}
