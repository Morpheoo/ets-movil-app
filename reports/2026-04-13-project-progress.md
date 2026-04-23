# Avance del Proyecto — ESCOM ETS Manager
**Fecha:** 2026-04-13  
**Rama activa:** `phase-0-skeleton`  
**Materia:** Desarrollo de Aplicaciones Móviles Nativas — Grupo 20262  
**Profesor:** Ing. José Antonio Ortiz Ramírez

---

## Estado General vs. Requerimientos del Proyecto

```
Módulo Público (Consulta)       ████████████████████  100% ✅
Módulo Admin (Gestión)          ████████████████░░░░   80% 🔄
Reqs. Técnicos "Irrenunciables" ████████████████████  100% ✅
Entorno de desarrollo           ██████████████████░░   90% 🔄
```

---

## Módulo Público — Requerimientos del Proyecto

| # | Requerimiento | Estado | Notas |
|---|---------------|--------|-------|
| 1 | Buscador por Carrera, Semestre y Materia | ✅ Completo | Filtros + debounce 250ms |
| 2 | Tabla: Materia, Fecha, Turno, Salón, Profesor | ✅ Completo | EtsCard + EtsDetailScreen |
| 3 | Exportación a PDF | ✅ Completo | `pdf` + `printing` |
| 3+ | Exportación a Excel | ✅ Completo | `excel` + `share_plus` |
| 3+ | Exportación a .ics (iCalendar) — puntos extra | ✅ Completo | `ics_generator.dart` con share |
| 4 | Calendario de exámenes guardados | ✅ Completo | `CalendarScreen` con navegación mensual |
| 5 | Favoritos con persistencia local | ✅ Completo | SQLite + notificaciones automáticas |

---

## Módulo Administrativo — Requerimientos del Proyecto

| # | Requerimiento | Estado | Notas |
|---|---------------|--------|-------|
| 1 | Login seguro | ⚠️ Parcial | UI lista + Failure handling; mock sin encriptación real |
| 2 | Dashboard con estadísticas por carrera | ✅ Completo | AdminDashboardScreen con barras |
| 3 | CRUD completo de exámenes | ⚠️ Parcial | ManageEtsScreen lista; sin backend real |
| 4 | Gestión de Catálogos (Carreras, Edificios/Salones) | ✅ Completo | `manage_catalogs_screen.dart` con domain layer |

---

## Requerimientos Técnicos "Irrenunciables"

| Req. | Descripción | Estado |
|------|-------------|--------|
| A | Dart / Flutter stable 3.x | ✅ |
| B | Riverpod — NO setState para lógica | ✅ AsyncNotifier en todos los providers |
| B | Clean Architecture (Data / Domain / Presentation) | ✅ |
| C | Consumo de API REST (Dio) | ✅ `DioClient` + `EtsRemoteDataSourceImpl` listo para backend |
| C | Modelos con serialización `fromJson` / `toJson` | ✅ `UserModel`, `EtsModel` |
| C | Manejo de errores de red en UI | ✅ Snackbar con mensaje por tipo de `Failure` |
| D | Caché local | ✅ sqflite para favoritos |
| D | Notificaciones locales | ✅ `NotificationService` + scheduling al guardar favorito |
| D | `url_launcher` | ✅ Guías y proyectos en EtsDetailScreen |
| — | `flutter analyze` 0 issues | ✅ Verificado 2026-04-13 |
| — | `get_it` + `injectable` para DI | ✅ `@LazySingleton` en datasources y repos |
| — | Datos mock en asset externo (no hardcoded) | ✅ `assets/data/ets_data.json` — migrado 2026-04-13 |

---

## Pantallas

### ✅ Completas

| Pantalla | Archivo |
|----------|---------|
| Splash Screen | `splash/presentation/splash_screen.dart` |
| Login Screen | `auth/presentation/login_screen.dart` |
| ETS List Screen | `ets/presentation/ets_list_screen.dart` |
| ETS Detail Screen | `ets/presentation/ets_detail_screen.dart` |
| ETS Card Widget | `ets/presentation/widgets/ets_card.dart` |
| Favorites Screen | `ets/presentation/favorites_screen.dart` |
| Calendar Screen | `ets/presentation/calendar_screen.dart` |
| Home Shell (nav) | `home/presentation/home_shell.dart` |
| Admin Shell (nav) | `admin/presentation/admin_shell.dart` |
| Admin Dashboard | `admin/presentation/admin_dashboard_screen.dart` |
| Manage ETS Screen | `admin/presentation/manage_ets_screen.dart` |
| Manage Catalogs Screen | `admin/presentation/manage_catalogs_screen.dart` |
| Profile Screen | `auth/presentation/profile_screen.dart` |

### ⚠️ Parciales

| Pantalla | Pendiente |
|----------|-----------|
| Admin - Users Tab | CRUD de usuarios (depende del backend) |
| Admin - Settings Tab | Configuración admin |
| Login | Encriptación real de contraseñas (cuando haya backend) |

---

## Fixes y Mejoras Aplicadas

| Fecha | Acción | Resultado |
|-------|--------|-----------|
| 2026-04-09 | `dart fix --apply` | Nothing to fix |
| 2026-04-09 | Reemplazar `withOpacity` → `withValues(alpha:)` | 0 issues |
| 2026-04-13 | Fix `GestureDetector + AbsorbPointer` → `readOnly + onTap` | Correcto Flutter idiom |
| 2026-04-13 | Migrar 93 exámenes mock a `assets/data/ets_data.json` | Mock: 130 líneas → 20 líneas |
| 2026-04-13 | `EtsModel.fromJson` soporta `projectUrl`/`project_url` | Compatibilidad JSON local + API |
| 2026-04-13 | Perfil PowerShell: `adb` en PATH + `CHROME_EXECUTABLE` | `adb devices` funcional post-reinicio |
| 2026-04-13 | Visual Studio Community 2022 instalándose | Flutter Windows desktop desbloqueado |

---

## Pendientes Menores

| # | Qué | Impacto |
|---|-----|---------|
| 1 | Credenciales hardcodeadas en `LoginScreen` (dev-only) | Quitar antes de release |
| 2 | Tests unitarios para `EtsListNotifier` y `AuthNotifier` | Puntos extra con el profesor |
| 3 | Backend real → cambiar 2 líneas en providers (ya documentado) | Req. C real |

---

## Para la Próxima Sesión

1. Verificar `flutter run -d windows` tras instalar Visual Studio ✅
2. Probar app en emulador Android (emulador online + `flutter run`)
3. Opcional: agregar tests unitarios básicos para los notifiers
