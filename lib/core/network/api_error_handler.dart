import 'package:dio/dio.dart';
import '../error/exceptions.dart';

// Convierte un DioException en la excepción personalizada correspondiente.
// Uso en datasources:
//   try {
//     final response = await _dio.get('/ets');
//     ...
//   } catch (e) {
//     throw ApiErrorHandler.handle(e);
//   }
class ApiErrorHandler {
  static Exception handle(Object error) {
    if (error is DioException) {
      return _fromDio(error);
    }
    return ServerException(message: error.toString());
  }

  static Exception _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const RequestTimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final message = _extractMessage(e);
        switch (status) {
          case 401:
            return const UnauthorizedException();
          case 404:
            return NotFoundException(message: message);
          default:
            return ServerException(message: message, statusCode: status);
        }

      default:
        return ServerException(message: e.message ?? 'Error inesperado');
    }
  }

  static String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String? ?? 'Error del servidor';
    }
    return e.message ?? 'Error del servidor';
  }
}
