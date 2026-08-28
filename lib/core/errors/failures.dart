sealed class Failure implements Exception {
  const Failure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.statusCode});
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Your session has expired.']);
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    super.message = 'You are not allowed to perform this action.',
  ]);
}

final class ApiFailure extends Failure {
  const ApiFailure(super.message, {super.statusCode});
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
