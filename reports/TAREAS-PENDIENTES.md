# Tareas Pendientes — ESCOM ETS Manager
**Proyecto:** Sistema para la Gestión de ETS  
**Materia:** Desarrollo de Aplicaciones Móviles Nativas — Grupo 20262  
**Profesor:** Ing. José Antonio Ortiz Ramírez  
**Stack:** Flutter + Dart, Riverpod, GoRouter, Dio, SQLite

---

## Contexto del proyecto

App móvil para que estudiantes de ESCOM (IPN) consulten y gestionen su calendario de ETS (Exámenes a Título de Suficiencia). Tiene módulo público (consulta) y módulo admin (CRUD).

**Arquitectura:** Clean Architecture — capas domain / data / presentation  
**Estado:** Riverpod con `AsyncNotifier`  
**Navegación:** GoRouter  
**HTTP:** Dio (configurado, pendiente conectar backend real)  
**DB local:** sqflite (favoritos funcionales)

---

## Lo que YA está hecho ✅

- Clean Architecture completa (domain / data / presentation) para features: auth, ets, home, admin, splash
- Riverpod con AsyncNotifier (sin setState para lógica)
- GoRouter con todas las rutas
- Material 3 con colores institucionales IPN/ESCOM
- `EtsModel` y `UserModel` con `fromJson` / `toJson` / `fromEntity`
- `DioClient` con timeouts (10s connect, 30s receive), headers JSON, LogInterceptor en debug
- `ApiErrorHandler` — convierte `DioException` → excepciones propias (`NetworkException`, `TimeoutException`, `ServerException`, etc.)
- `Failure` types: `ServerFailure`, `NetworkFailure`, `TimeoutFailure`, `UnauthorizedFailure`, `NotFoundFailure`, `CacheFailure`
- Repositorios mapean excepciones → failures correctamente
- `AuthRemoteDataSourceImpl` (Dio + `UserModel.fromJson`) + `AuthRemoteDataSourceMock` (datos fake por `fromJson`)
- `EtsRemoteDataSourceImpl` (Dio + `EtsModel.fromJson`) + `EtsRemoteDataSourceMock` (305 registros reales del período ETS Especial 2026-1)
- `dioClientProvider` compartido en `core/providers/core_providers.dart`
- Favoritos con SQLite funcionales
- `flutter analyze`: **0 issues**

---

## Tareas pendientes (por prioridad)

### 🔴 Irrenunciables del proyecto

#### 1. Manejo de errores de red en la UI
Los `Failure` ya se propagan hasta el provider. Falta mostrarlos con Snackbar o Dialog.

**Dónde:** `lib/features/ets/presentation/ets_list_screen.dart` y `lib/features/auth/presentation/login_screen.dart`

**Qué hacer:**
- En `ets_list_screen.dart`, cuando `etsState.hasError`, verificar el tipo de error y mostrar Snackbar con mensaje apropiado
- En `login_screen.dart`, el listener ya muestra Snackbar genérico — personalizarlo por tipo de `Failure`
- Importar `Failure` types desde `lib/core/error/failures.dart`

```dart
// Ejemplo en login_screen.dart (ref.listen):
if (next.hasError) {
  final failure = next.error;
  String msg = 'Error inesperado';
  if (failure is NetworkFailure) msg = failure.message;
  if (failure is UnauthorizedFailure) msg = failure.message;
  if (failure is TimeoutFailure) msg = failure.message;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
```

---

#### 2. Notificaciones locales
El profesor lo pide explícitamente como "capacidad nativa".

**Paquete a agregar en `pubspec.yaml`:**
```yaml
flutter_local_notifications: ^17.0.0
```

**Qué hacer:**
1. Crear `lib/core/notifications/notification_service.dart` con:
   - `initialize()` — setup del plugin
   - `scheduleEtsReminder(EtsEntity ets)` — programa alarma 1 día antes del examen
   - `cancelReminder(String id)` — cancela por id
2. Llamar `scheduleEtsReminder` al guardar un favorito en `SavedEtsNotifier.toggleSave()`
3. Llamar `cancelReminder` al eliminar favorito

**Archivo clave:** `lib/features/ets/presentation/providers/ets_provider.dart` → `SavedEtsNotifier.toggleSave()`

---

#### 3. Activar API REST real
Cuando el backend esté disponible, solo cambiar **una línea** en cada provider:

**`lib/features/auth/presentation/providers/auth_provider.dart`:**
```dart
// Cambiar:
return AuthRemoteDataSourceMock();
// Por:
return AuthRemoteDataSourceImpl(ref.watch(dioClientProvider));
```

**`lib/features/ets/presentation/providers/ets_provider.dart`:**
```dart
// Cambiar:
return EtsRemoteDataSourceMock();
// Por:
return EtsRemoteDataSourceImpl(ref.watch(dioClientProvider));
```

**URL base del backend** está en `lib/core/network/dio_client.dart` → `_baseUrl`

---

### 🟡 Importantes (módulos incompletos)

#### 4. Exportación a PDF del calendario
El profesor lo pide en el Módulo Público.

**Paquete:** `pdf: ^3.10.0` + `printing: ^5.12.0`

**Dónde agregar el botón:** `lib/features/ets/presentation/ets_list_screen.dart` — botón en el AppBar o FAB

**Qué exportar:** La lista filtrada actual de `EtsEntity` como tabla (Materia, Fecha, Turno, Salón, Profesor)

---

#### 5. Implementar get_it + injectable para DI
El profesor lo **valora positivamente**. Actualmente declarado en `pubspec.yaml` pero sin usar.

**Qué hacer:**
1. Anotar datasources y repositorios con `@injectable`, `@LazySingleton`
2. Crear `lib/core/di/injection.dart` con `@InjectableInit`
3. Correr `dart run build_runner build`
4. Reemplazar los `Provider` manuales de Riverpod con los servicios registrados en get_it

---

#### 6. Gestión de Catálogos (Admin)
El profesor pide CRUD de Carreras y Edificios/Salones.

**Dónde:** `lib/features/admin/presentation/` — crear `manage_catalogs_screen.dart`

**Qué incluir:** Lista de carreras (ISC, IIA, LCD, ISISA) y salones con posibilidad de agregar/editar/eliminar

---

#### 7. Calendar Tab
Tab de calendario en `HomeShell` actualmente es placeholder.

**Dónde:** `lib/features/home/presentation/home_shell.dart` → `_CalendarPlaceholder`

**Qué hacer:** Mostrar los exámenes guardados en una vista de calendario por fecha (paquete `table_calendar` recomendado)

---

### 🟢 Puntos extra

#### 8. Exportación a .ics (iCalendar)
**Paquete:** `ical: ^2.0.0` o generar el formato manualmente (es texto plano)

**Qué exportar:** Los exámenes guardados como eventos de calendario compatibles con Google Calendar / iOS Calendar

---

## Estructura de archivos relevantes

```
lib/
├── core/
│   ├── error/
│   │   ├── exceptions.dart      ← excepciones de capa data
│   │   └── failures.dart        ← failures de capa domain
│   ├── network/
│   │   ├── dio_client.dart      ← Dio configurado (cambiar _baseUrl aquí)
│   │   └── api_error_handler.dart ← DioException → Exception
│   ├── providers/
│   │   └── core_providers.dart  ← dioClientProvider
│   └── data/local/
│       └── database_helper.dart ← SQLite singleton
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/auth_remote_data_source.dart  ← Mock + Real (Dio)
│   │   │   ├── models/user_model.dart                    ← fromJson / toJson
│   │   │   └── repositories/auth_repository_impl.dart   ← Exception → Failure
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       └── providers/auth_provider.dart              ← swap Mock↔Real aquí
│   └── ets/
│       ├── data/
│       │   ├── datasources/ets_remote_data_source.dart   ← Mock + Real (Dio)
│       │   ├── models/ets_model.dart                     ← fromJson / toJson
│       │   └── repositories/ets_repository_impl.dart    ← Exception → Failure
│       └── presentation/
│           ├── ets_list_screen.dart    ← agregar manejo de error UI aquí
│           ├── ets_detail_screen.dart
│           ├── favorites_screen.dart
│           └── providers/ets_provider.dart  ← swap Mock↔Real aquí
```

---

## Comandos útiles

```bash
# Verificar que no hay errores
flutter analyze

# Correr en Android
flutter run

# Generar código de injectable (cuando se implemente DI)
dart run build_runner build --delete-conflicting-outputs
```
