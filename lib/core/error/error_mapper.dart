import 'app_exception.dart';

String mapErrorToMessage(
  Object error, {
  String fallbackMessage = 'Ocurrio un error inesperado. Intenta nuevamente.',
}) {
  if (error is AppException) {
    switch (error.type) {
      case AppExceptionType.network:
        return 'No hay conexion a internet o la solicitud excedio el tiempo de espera. Intenta nuevamente.';
      case AppExceptionType.server:
        final code = error.statusCode;
        if (code != null) {
          return 'Error del servidor ($code). Intenta nuevamente.';
        }
        return 'Error del servidor. Intenta nuevamente.';
      case AppExceptionType.parsing:
        return 'Se recibio un formato de datos inesperado desde el servidor.';
      case AppExceptionType.unknown:
        return error.message ?? fallbackMessage;
    }
  }

  return fallbackMessage;
}