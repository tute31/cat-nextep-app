enum AppExceptionType {
  network,
  server,
  parsing,
  unknown,
}

class AppException implements Exception {
  const AppException({
    required this.type,
    this.message,
    this.statusCode,
  });

  final AppExceptionType type;
  final String? message;
  final int? statusCode;
}