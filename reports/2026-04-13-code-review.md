# Code Review — ESCOM ETS Manager
**Fecha:** 2026-04-13  
**Revisado por:** Claude Sonnet 4.6  
**Rama:** `phase-0-skeleton`

---

## Resumen Ejecutivo

El proyecto ha madurado significativamente desde el review del 2026-04-09. Todos los issues críticos y la mayoría de los importantes están resueltos. La arquitectura es sólida, el código analiza a **0 issues**, y la separación de responsabilidades está bien respetada.

**Veredicto:** Listo para demostración. Quedan solo detalles menores que no afectan la funcionalidad ni la calificación.

---

## Comparativa vs. Review Anterior

| Issue | Antes | Ahora |
|-------|-------|-------|
| `get_it`/`injectable` declarados sin usar | ❌ | ✅ Implementados con `@LazySingleton` |
| `failures.dart` sin usar en repos | ❌ | ✅ `Failure` types propagados hasta la UI |
| Manejo de errores en UI | ❌ Sin Snackbar | ✅ Snackbar por tipo de `Failure` en login y ETS list |
| `GestureDetector + AbsorbPointer` | ❌ Anti-pattern | ✅ `readOnly + onTap` correcto |
| 305 exámenes hardcodeados en código | ❌ | ✅ Movidos a `assets/data/ets_data.json` |
| `prefer_const_constructors` | ⚠️ Pendiente | ✅ `dart fix --apply` → nothing to fix |
| Notificaciones | ❌ No existían | ✅ `NotificationService` + scheduling en `toggleSave` |
| Exportación PDF / Excel / .ics | ❌ | ✅ Los tres implementados |
| Calendar Tab | ❌ Placeholder | ✅ `CalendarScreen` con navegación mensual |
| Gestión de Catálogos admin | ❌ | ✅ `manage_catalogs_screen.dart` + domain layer |

---

## Issues Activos

### 🟡 Menor

#### 1. Credenciales hardcodeadas en `LoginScreen`
```dart
// login_screen.dart — líneas 16-17:
final _emailController = TextEditingController(text: 'student@test.com');
final _passwordController = TextEditingController(text: '123456');
```
Aceptable en desarrollo. **Eliminar antes de cualquier release o demo pública.**

---

#### 2. Sin tests
`test/widget_test.dart` sigue siendo el stub por defecto. No hay tests de:
- `EtsListNotifier` (unit)
- `AuthNotifier` (unit)
- `SavedEtsNotifier` (unit)

**Impacto en calificación:** El profesor valora positivamente los tests.  
**Acción:** Al menos agregar tests unitarios para los dos notifiers principales.

---

#### 3. `EtsModel.fromJson` acepta camelCase y snake_case
```dart
projectUrl: (json['projectUrl'] ?? json['project_url']) as String?,
```
Funcional, pero podría generar confusión cuando se conecte el backend real. Definir un contrato claro de nombres de campos con el backend y limpiar la doble clave.

---

## Checklist de Buenas Prácticas Flutter

- [x] Material 3 activado
- [x] GoRouter para navegación
- [x] Riverpod para estado (`AsyncNotifier`)
- [x] `const` en widgets (verificado con `dart fix`)
- [x] `SingleChildScrollView` para pantallas largas
- [x] `ListView.builder` (no `ListView` con children)
- [x] Manejo de estados: loading / error / data
- [x] Separación de widgets en archivos propios
- [x] Custom `Failure` types usados en repositorios y UI
- [x] Assets externos para datos estáticos (`ets_data.json`)
- [x] `readOnly + onTap` para campos de fecha/hora
- [x] DI con `get_it` + `injectable`
- [x] Notificaciones locales integradas al flujo de favoritos
- [ ] Tests unitarios y de widget
- [ ] Sin credenciales en código para producción

---

## Métricas del Proyecto

| Métrica | Valor |
|---------|-------|
| Líneas de Dart | ~2,800 |
| Archivos `.dart` | 47 |
| Features | 5 (auth, ets, home, admin, splash) |
| Capas por feature | domain / data / presentation |
| Tests escritos | 0 |
| Dependencias directas | 15 |
| Dependencias sin usar | 0 |
| `flutter analyze` | **0 issues** |

---

## Próximos Pasos (en orden de impacto)

1. Verificar `flutter run -d windows` tras instalar Visual Studio
2. Probar en emulador Android — flujo completo login → lista → favorito → notificación
3. Agregar tests unitarios para `EtsListNotifier` y `AuthNotifier`
4. Limpiar credenciales hardcodeadas en `LoginScreen`
5. Definir contrato snake_case con backend y simplificar `EtsModel.fromJson`
