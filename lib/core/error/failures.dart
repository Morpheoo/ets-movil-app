abstract class Failure {
  final String message;
  const Failure(this.message);
}

// Error de servidor (4xx/5xx)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Sin conexión a internet
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Timeout de la solicitud
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message);
}

// Credenciales inválidas o sesión expirada (401)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

// Recurso no encontrado (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

// Error al leer/escribir base de datos local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
