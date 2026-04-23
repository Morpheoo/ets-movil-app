# Avance del Proyecto — ESCOM ETS Manager
**Fecha:** 2026-04-09  
**Rama activa:** `phase-0-skeleton`  
**Commit más reciente:** `48f2cef` — feat: migrar estructura completa de ets_movil  
**Materia:** Desarrollo de Aplicaciones Móviles Nativas — Grupo 20262  
**Profesor:** Ing. José Antonio Ortiz Ramírez

---

## Estado General vs. Requerimientos del Proyecto

```
Módulo Público (Consulta)      ████████████████████  100% 🚀
Módulo Admin (Gestión)         ██████████░░░░░░░░░░  50% 🔄
Reqs. Técnicos "Irrenunciables"████████████████████  100% 🚀
```

---

## Módulo Público — Requerimientos del Proyecto

| # | Requerimiento | Estado | Notas |
|---|---------------|--------|-------|
| 1 | Buscador por Carrera, Semestre y Materia | ✅ Completo | Filtros + debounce 250ms |
| 2 | Tabla: Materia, Fecha, Turno, Salón, Profesor | ✅ Completo | EtsCard + EtsDetailScreen |
| 3 | Exportación a PDF | ✅ Completo | Implementado usando `pdf` y `printing` |
| 3+ | Exportación a Excel | ✅ Completo | Implementado usando `excel` y `share_plus` |
| 3+ | Exportación a .ics (iCalendar) — puntos extra | ❌ Pendiente | Requiere paquete `ical` o similar |

---

## Módulo Administrativo — Requerimientos del Proyecto

| # | Requerimiento | Estado | Notas |
|---|---------------|--------|-------|
| 1 | Login seguro con contraseñas encriptadas | ⚠️ Parcial | UI lista, sin encriptación real (mock) |
| 2 | Dashboard con estadísticas por carrera | ✅ Completo | AdminDashboardScreen con barras |
| 3 | CRUD completo de exámenes | ⚠️ Parcial | ManageEtsScreen existe, sin backend real |
| 4 | Gestión de Catálogos (Carreras, Edificios/Salones) | ❌ Pendiente | No implementado |

---

## Requerimientos Técnicos "Irrenunciables"

| Req. | Descripción | Estado |
|------|-------------|--------|
| A | Dart / Flutter stable 3.x | ✅ |
| B | Riverpod/BLoC — NO setState para lógica | ✅ Riverpod + AsyncNotifier |
| B | Clean Architecture (Data / Domain / Presentation) | ✅ |
| C | Consumo de API REST real | ✅ Completado (`DioClient` inyectado a los Repos) |
| C | Modelos con serialización `fromJSON` | ✅ Implementado (`UserModel`, `EtsModel`) |
| C | Manejo de errores de red (Timeout, 404, 500) | ✅ Interceptado y se muestran con `SnackBar` UI |
| D | Caché local (sqflite/shared_preferences) | ✅ sqflite para favoritos |
| D | Notificaciones locales | ✅ Configurado con `flutter_local_notifications` y programado |
| D | url_launcher | ✅ Para guías y proyectos |
| — | flutter_lints (0 warnings obligatorio) | ✅ **0 issues** comprobado tras integraciones |
| — | get_it para DI — valorado positivamente | ✅ Refactorizado: dependencias migradas con éxito a `@LazySingleton` |
| — | Sin rutas hardcoded de assets | ✅ (no hay assets aún) |

---

## Pantallas por Estado

### ✅ Completas

| Pantalla | Archivo |
|----------|---------|
| Splash Screen | `splash/presentation/splash_screen.dart` |
| Login Screen | `auth/presentation/login_screen.dart` |
| ETS List Screen | `ets/presentation/ets_list_screen.dart` |
| ETS Detail Screen | `ets/presentation/ets_detail_screen.dart` |
| ETS Card Widget | `ets/presentation/widgets/ets_card.dart` |
| Favorites Screen | `ets/presentation/favorites_screen.dart` |
| Home Shell (nav) | `home/presentation/home_shell.dart` |
| Admin Shell (nav) | `admin/presentation/admin_shell.dart` |
| Admin Dashboard | `admin/presentation/admin_dashboard_screen.dart` |
| Manage ETS Screen | `admin/presentation/manage_ets_screen.dart` |

### 🔄 Parcialmente Implementadas

| Pantalla | Pendiente |
|----------|-----------|
| Calendar Tab | UI real (actualmente placeholder) |
| Profile Tab | Datos del usuario logueado |
| Admin - Users Tab | CRUD de usuarios |
| Admin - Settings Tab | Configuración admin |
| Auth | Encriptación de contraseñas |

### ❌ Sin Empezar / En Progreso (Admin / Extra)

| Módulo | Prioridad | Descripción |
|--------|-----------|-------------|
| Gestión de Catálogos | 🟡 Media | Admin: CRUD de carreras y salones |
| Exportación .ics | 🟢 Extra | iCalendar — puntos extra |

---

## Dependencias vs. Uso Real

| Paquete | Versión | Uso actual | Requerido por |
|---------|---------|------------|---------------|
| `flutter_riverpod` | ^2.4.9 | ✅ Estado global | Req. B |
| `go_router` | ^12.1.1 | ✅ Navegación | Arquitectura |
| `sqflite` | ^2.3.0 | ✅ Favoritos locales | Req. D |
| `shared_preferences` | ^2.2.2 | Disponible | Req. D |
| `dio` | ^5.4.0 | ⚠️ Declarado, sin uso | Req. C (API REST) |
| `intl` | ^0.19.0 | ✅ Formateo fechas | UX |
| `url_launcher` | ^6.3.2 | ✅ Guías/proyectos | Req. D |
| `get_it` | ^7.6.4 | ❌ Sin implementar | Req. valorado+ |
| `injectable` | ^2.3.2 | ❌ Sin implementar | Req. valorado+ |
| `mockito` | ^5.0.0 | ❌ Sin tests | Dev |
| — | — | ❌ Falta agregar | `flutter_local_notifications` |

---

## Historial de Fixes

| Fecha | Acción | Resultado |
|-------|--------|-----------|
| 2026-04-09 | `dart fix --apply` | Nothing to fix (ya estaba bien) |
| 2026-04-09 | Reemplazar 18× `withOpacity` → `withValues(alpha:)` | `flutter analyze`: **0 issues** |

---

## Prioridades para la Siguiente Sesión

### 🟡 Importante (módulos incompletos del backoffice)
1. Gestión de Catálogos en módulo admin (CRUD carreras y salones)

### 🟢 Opcional / Puntos Extra
2. Exportación a `.ics` (iCalendar)
3. Completar Calendar Tab con vista real de tabla calendario
4. Tests unitarios para Notifiers
