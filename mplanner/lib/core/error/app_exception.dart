sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause, super.stackTrace, this.statusCode});
  final int? statusCode;
}

class ParsingException extends AppException {
  const ParsingException(super.message, {super.cause, super.stackTrace});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.cause, super.stackTrace});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause, super.stackTrace});
}