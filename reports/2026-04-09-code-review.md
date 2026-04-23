# Code Review — ESCOM ETS Manager
**Fecha:** 2026-04-09  
**Revisado por:** Claude Sonnet 4.6  
**Rama:** `phase-0-skeleton`  
**Skill aplicada:** `flutter-development`

---

## Resumen Ejecutivo

El proyecto tiene una base arquitectónica sólida. Se usa **Clean Architecture** con separación clara entre domain, data y presentation. **Riverpod** con `AsyncNotifier` está bien aplicado y **GoRouter** cubre la navegación de forma moderna. El tema institucional (colores IPN/ESCOM) está centralizado correctamente en `AppTheme`.

**Veredicto general:** Base buena. Hay deuda técnica identificable y correcciones de estilo pendientes, pero nada estructuralmente roto.

---

## Fortalezas

| # | Área | Detalle |
|---|------|---------|
| 1 | Arquitectura | Clean Architecture con capas domain/data/presentation bien separadas |
| 2 | State Management | `AsyncNotifier` + `AsyncValue` manejando loading/error/data correctamente |
| 3 | Navegación | GoRouter con rutas tipadas y paso de `extra` para entidades |
| 4 | Tema | `AppTheme` centralizado, Material 3, colores institucionales definidos en `AppColors` |
| 5 | Persistencia | SQLite con `DatabaseHelper` singleton para favoritos |
| 6 | Filtros | Filtrado por carrera + semestre + búsqueda de texto con debounce (250ms) |
| 7 | UX | Estados vacío/carga/error correctamente manejados en `EtsListScreen` |
| 8 | Estructura | Feature-based folders (`auth/`, `ets/`, `home/`, `admin/`, `splash/`) |

---

## Problemas Identificados

### 🔴 Crítico

#### 1. Dependencias no utilizadas en `pubspec.yaml`
```yaml
# Declaradas pero sin uso real en el código:
get_it: ^7.6.4
injectable: ^2.3.2
```
**Por qué importa:** Aumentan el peso del build, confunden a quien lee el proyecto (¿se usa DI o no?), y `injectable` requiere code generation que nunca se ejecutó.

**Acción:** Eliminar ambas o implementarlas para reemplazar los providers manuales.

---

#### 2. `failures.dart` existe pero no se usa
`lib/core/error/failures.dart` define `Failure`, `ServerFailure` y `CacheFailure`, pero los repositorios lanzan `Exception` genérico:

```dart
// auth_repository_impl.dart — línea actual:
} catch (e) {
  rethrow; // lanza Exception genérico
}

// Lo correcto con la arquitectura definida:
} catch (e) {
  throw ServerFailure(message: e.toString());
}
```
**Acción:** Usar `Failure` en todos los repositorios y propagarlos a los providers.

---

### 🟡 Importante

#### 3. Magic strings de carreras en múltiples archivos
El código `'ISC'`, `'IIA'`, `'LCD'`, `'ISISA'` está hardcodeado en:
- `lib/features/ets/domain/entities/ets_entity.dart`
- `lib/features/ets/presentation/widgets/ets_card.dart`
- `lib/features/ets/presentation/ets_list_screen.dart`

**Acción:** Crear un `enum Career { isc, iia, lcd, isisa }` en la capa domain con extensión para nombre corto y nombre completo.

---

#### 4. `GestureDetector + AbsorbPointer` en `ManageEtsScreen`
```dart
// Patrón incorrecto (manage_ets_screen.dart):
GestureDetector(
  onTap: () => _selectDate(context),
  child: AbsorbPointer(
    child: TextFormField(...)
  ),
)

// Patrón correcto Flutter:
TextFormField(
  readOnly: true,
  onTap: () => _selectDate(context),
)
```
**Acción:** Reemplazar todos los campos de fecha/hora con `readOnly: true` + `onTap`.

---

#### 5. Datos mock hardcodeados en código (305 exámenes)
`ets_remote_data_source.dart` contiene 305 objetos `EtsEntity` en un método de 139 líneas. Esto:
- Dificulta actualizar datos sin tocar lógica
- Viola separación de responsabilidades

**Acción:** Mover los datos a `assets/data/ets_data.json` y cargarlos con `rootBundle.loadString()`.

---

#### 6. Comentarios obsoletos en `auth_repository.dart`
Hay comentarios referenciando `dartz` y el patrón `Either<Failure, T>` que nunca se implementó:
```dart
// Using Either from dartz for functional error handling
// TODO: implement with Either pattern
```
**Acción:** Eliminar o implementar. No dejar TODOs sin contexto de por qué están ahí.

---

### 🟢 Menor / Estilo

#### 7. `prefer_const_constructors` — incumplimiento potencial
`analysis_options.yaml` activa esta regla, pero varios widgets no usan `const` donde podrían:
```dart
// Sin const (menos eficiente):
child: Text('ESCOM ETS Manager')

// Con const (mejor):
child: const Text('ESCOM ETS Manager')
```
**Acción:** Correr `dart fix --apply` para aplicar automáticamente.

#### 8. Sin tests
`test/widget_test.dart` solo tiene el stub por defecto de Flutter. No hay tests de:
- Providers (unit)
- Repositorios (unit con mocks)
- Widgets críticos (widget tests)

**Acción:** Como mínimo, agregar tests unitarios para `EtsListNotifier` y `AuthNotifier`.

#### 9. Credenciales hardcodeadas en `LoginScreen`
```dart
// login_screen.dart — los controllers se inicializan con valores:
_emailController = TextEditingController(text: 'student@test.com');
_passwordController = TextEditingController(text: '123456');
```
Está bien para desarrollo, pero debe eliminarse antes de cualquier release.

---

## Métricas del Proyecto

| Métrica | Valor |
|---------|-------|
| Líneas de Dart | ~2,500 |
| Archivos `.dart` | 20 |
| Features | 5 (auth, ets, home, admin, splash) |
| Capas por feature | domain / data / presentation |
| Tests escritos | 0 |
| Dependencias directas | 12 |
| Dependencias no usadas | 2 (`get_it`, `injectable`) |

---

## Checklist de Buenas Prácticas Flutter

- [x] Material 3 activado
- [x] GoRouter para navegación
- [x] Riverpod para estado
- [x] `const` en widgets donde aplica (parcial)
- [x] `SingleChildScrollView` para pantallas largas
- [x] `ListView.builder` (no `ListView` con children)
- [x] Manejo de estados: loading / error / data
- [x] Separación de widgets en archivos propios (`ets_card.dart`)
- [ ] Enum para valores fijos (carreras)
- [ ] Custom `Failure` types usados en repositorios
- [ ] Assets externos para datos estáticos grandes
- [ ] Tests unitarios y de widget
- [ ] Sin credenciales en código para producción
- [ ] Sin dependencias sin usar en `pubspec.yaml`

---

## Próximos Pasos Sugeridos

1. Correr `dart fix --apply` para resolver `const` automáticamente
2. Eliminar `get_it` e `injectable` de `pubspec.yaml`
3. Crear `enum Career` y eliminar magic strings
4. Reemplazar `GestureDetector + AbsorbPointer` por `readOnly + onTap`
5. Mover datos mock a JSON en assets
6. Usar `ServerFailure` / `CacheFailure` en repositorios
7. Agregar al menos tests unitarios para los notifiers
