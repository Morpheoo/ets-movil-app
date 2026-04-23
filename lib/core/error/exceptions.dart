// Excepciones de la capa de datos.
// Los repositorios capturan estas y las convierten en [Failure].

/// Error de servidor (4xx/5xx).
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Sin conexión a internet o host no alcanzable.
class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'NetworkException: sin conexión a internet';
}

/// La solicitud tardó demasiado (connect/send/receive timeout).
class RequestTimeoutException implements Exception {
  const RequestTimeoutException();

  @override
  String toString() => 'RequestTimeoutException: tiempo de espera agotado';
}

/// El servidor respondió 401 — credenciales inválidas o sesión expirada.
class UnauthorizedException implements Exception {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException: no autorizado';
}

/// El recurso solicitado no existe (404).
class NotFoundException implements Exception {
  final String message;

  const NotFoundException({required this.message});

  @override
  String toString() => 'NotFoundException: $message';
}

/// Error al leer/escribir en la base de datos local.
class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}
