# ESCOM ETS Manager — Estado Consolidado
**Última actualización:** 2026-05-13
**Rama activa:** `phase-0-skeleton`
**Materia:** Desarrollo de Aplicaciones Móviles Nativas — Grupo 20262
**Profesor:** Ing. José Antonio Ortiz Ramírez
**Stack:** Flutter 3.x + Dart, Riverpod (AsyncNotifier), GoRouter, Dio, sqflite, get_it+injectable, flutter_local_notifications, pdf/printing, excel/share_plus

---

## 1. Resumen ejecutivo

```
Módulo Público (Consulta)       ████████████████████  100%  ✅
Módulo Admin (Gestión)          ███████████████░░░░░   75%  🔄
Reqs. Técnicos "Irrenunciables" ████████████████████  100%  ✅
Pulido / Calidad                ██████████████░░░░░░   70%  🔄
```

**Veredicto:** Listo para demostración. La arquitectura es sólida (Clean Arch + Riverpod + get_it), `flutter analyze` reporta **0 issues**, y el flujo end-to-end (login → lista → favorito → notificación → exportar) está completo. Faltan **tests** y limpieza de placeholders en el admin para tener el proyecto "release-ready".

---

## 2. Módulo Público — Requerimientos del Proyecto

| # | Requerimiento | Estado | Notas |
|---|---|---|---|
| 1 | Buscador por Carrera, Semestre y Materia | ✅ | Chips + debounce 250ms |
| 2 | Tabla: Materia, Fecha, Turno, Salón, Profesor | ✅ | `EtsCard` + `EtsDetailScreen` |
| 3 | Exportación a PDF | ✅ | `pdf` + `printing` (FAB azul) |
| 3+ | Exportación a Excel | ✅ | `excel` + `share_plus` (FAB verde) |
| 3+ | Exportación a `.ics` (puntos extra) | ✅ | `ics_generator.dart` con share |
| 4 | Calendario de exámenes | ✅ | `CalendarScreen` mensual con dots por carrera |
| 5 | Favoritos con persistencia local | ✅ | SQLite + notificación automática |

---

## 3. Módulo Administrativo — Requerimientos del Proyecto

| # | Requerimiento | Estado | Notas |
|---|---|---|---|
| 1 | Login seguro | ⚠️ | UI lista + `Failure` handling; mock sin encriptación real |
| 2 | Dashboard con estadísticas por carrera | ✅ | `AdminDashboardScreen` con barras |
| 3 | CRUD de exámenes | ⚠️ | `ManageEtsScreen` tiene UI completa pero `_onSave` solo muestra Snackbar; lista en `AdminShell._ExamsManageScreen` está hardcodeada |
| 4 | Gestión de Catálogos (Carreras + Salones) | ✅ | `ManageCatalogsScreen` + capa domain |

---

## 4. Requerimientos Técnicos "Irrenunciables"

| Req. | Descripción | Estado |
|---|---|---|
| A | Dart / Flutter stable 3.x (`sdk: ^3.10.8`) | ✅ |
| B | Riverpod — sin `setState` para lógica | ✅ `AsyncNotifier` en todos los providers |
| B | Clean Architecture (Data / Domain / Presentation) | ✅ |
| C | Consumo de API REST (Dio) | ✅ `DioClient` + `EtsRemoteDataSourceImpl` listo (un swap de `@LazySingleton` lo activa) |
| C | Modelos con serialización `fromJson` / `toJson` | ✅ `UserModel`, `EtsModel` |
| C | Manejo de errores de red en UI | ✅ Snackbar por tipo de `Failure` en login y lista |
| D | Caché local | ✅ `sqflite` para favoritos |
| D | Notificaciones locales | ✅ `NotificationService` con scheduling 1 día antes |
| D | `url_launcher` | ✅ Guías y proyectos en `EtsDetailScreen` |
| — | `flutter_lints` 0 warnings | ✅ verificado 2026-05-13 |
| — | `get_it` + `injectable` para DI | ✅ `@LazySingleton` en datasources y repos |
| — | Datos mock en asset externo (no hardcoded) | ✅ `assets/data/ets_data.json` |

---

## 5. Pantallas

### ✅ Completas

| Pantalla | Archivo |
|---|---|
| Splash | `splash/presentation/splash_screen.dart` |
| Login | `auth/presentation/login_screen.dart` |
| ETS List | `ets/presentation/ets_list_screen.dart` |
| ETS Detail | `ets/presentation/ets_detail_screen.dart` |
| Favorites | `ets/presentation/favorites_screen.dart` |
| Calendar | `ets/presentation/calendar_screen.dart` |
| Home Shell | `home/presentation/home_shell.dart` |
| Admin Shell | `admin/presentation/admin_shell.dart` |
| Admin Dashboard | `admin/presentation/admin_dashboard_screen.dart` |
| Manage Catalogs | `admin/presentation/manage_catalogs_screen.dart` |
| Profile | `auth/presentation/profile_screen.dart` |

### ⚠️ Parciales

| Pantalla | Pendiente |
|---|---|
| Manage ETS | `_onSave` no persiste; usa lista hardcodeada en lugar de `etsListProvider` |
| Admin Shell — Exams tab | Reemplazar 3 tiles hardcodeados (`Cálculo I`, etc.) por la lista real |
| Admin Shell — Settings tab | Placeholder "Configuración próximamente" |
| Login | Encriptación real al conectar backend |

---

## 6. Issues activos (por prioridad)

### 🟡 Menor

#### Credenciales hardcodeadas en LoginScreen
`login_screen.dart:16-17` — `student@test.com` / `123456`. Aceptable en dev, quitar antes de demo pública.

#### `SavedEtsNotifier` sin tests
Cubierto: `EtsListNotifier` (7 tests) y `AuthNotifier` (5 tests) + smoke test de `LoginScreen`. Faltaría `SavedEtsNotifier` — toggleSave idempotente y disparo de notificación.

#### `EtsModel.fromJson` acepta camelCase y snake_case
```dart
projectUrl: (json['projectUrl'] ?? json['project_url']) as String?,
```
Funcional pero ambiguo. Cuando se defina el contrato con backend, dejar solo uno.

#### `manage_ets_screen.dart` — lista de carreras incorrecta
Tiene `'Ingeniería en Sistemas de Información'` cuando la app maneja **ISISA** (Sistemas Automotrices). Inconsistente con `EtsEntity.careerFullName` y `_careerFullName` local que mapea `'IA'` en vez de `'IIA'`.

#### `NotificationService.scheduleEtsReminder` — catch silencioso
```dart
} catch (e) {
  // Ignored intentionally, or use a proper logger instead of print
}
```
Si falla el scheduling, no hay forma de saberlo. Al menos un `debugPrint` en `kDebugMode`.

---

## 7. Estructura del proyecto

```
lib/
├── core/
│   ├── config/      app_router.dart, app_theme.dart
│   ├── data/local/  database_helper.dart           ← SQLite singleton
│   ├── di/          injection.dart + .config.dart  ← injectable generado
│   ├── error/       exceptions.dart, failures.dart
│   ├── network/     dio_client.dart, api_error_handler.dart
│   ├── notifications/ notification_service.dart
│   ├── providers/   core_providers.dart            ← dioClientProvider
│   └── utils/       pdf_generator.dart, excel_generator.dart, ics_generator.dart
└── features/
    ├── auth/      domain · data · presentation
    ├── ets/       domain · data · presentation (List, Detail, Favorites, Calendar)
    ├── admin/     domain (catálogos) · data · presentation (Dashboard, ManageEts, ManageCatalogs)
    ├── home/      presentation (HomeShell con tabs)
    └── splash/    presentation
```

**Datos:** `assets/data/ets_data.json` (período ETS Especial 2026-1)

---

## 8. Comandos útiles

```powershell
# Verificar análisis estático
flutter analyze

# Correr tests
flutter test

# Correr en Windows desktop
flutter run -d windows

# Correr en Android (con device conectado vía adb)
flutter run

# Regenerar injectable tras anotar nuevas clases
dart run build_runner build --delete-conflicting-outputs
```

---

## 9. Para activar backend real

Cuando exista API REST, **dos cambios de una línea**:

1. `lib/features/auth/data/datasources/auth_remote_data_source.dart` — mover `@LazySingleton(as: AuthRemoteDataSource)` de `AuthRemoteDataSourceMock` a `AuthRemoteDataSourceImpl`
2. `lib/features/ets/data/datasources/ets_remote_data_source.dart` — mismo swap

3. `lib/core/network/dio_client.dart` — ajustar `_baseUrl`

4. `dart run build_runner build --delete-conflicting-outputs`

---

## 10. Métricas

| Métrica | Valor |
|---|---|
| `flutter analyze` | **0 issues** |
| `flutter test` | **13/13 passing** |
| Archivos `.dart` | 47 (+3 tests) |
| Líneas de Dart | ~2,800 |
| Features | 5 |
| Capas por feature | domain / data / presentation |
| Dependencias directas | 15 |
| Dependencias sin usar | 0 |

---

## 11. Historial relevante

| Fecha | Hito |
|---|---|
| 2026-04-09 | Code review inicial — base sólida, `get_it`/`injectable` sin usar, `failures.dart` sin usar |
| 2026-04-13 | Refactor mayor: DI con `@LazySingleton`, `Failure` propagado a UI, mock movido a JSON, PDF/Excel/.ics, calendar real, catálogos admin |
| 2026-05-13 | Consolidación de reportes; identificado test stub roto, lista admin hardcodeada, catch silencioso en notificaciones |
| 2026-05-13 | Tests: reemplazado stub por smoke de LoginScreen + 7 tests de `EtsListNotifier` + 5 de `AuthNotifier` — **13/13 passing** |

