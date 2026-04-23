# ets_movil

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Ejecutar Android con un solo comando (Windows)

Desde la raiz del proyecto:

```powershell
powershell -ExecutionPolicy Bypass -File .\run-android.ps1
```

Opcional: indicar un AVD especifico.

```powershell
powershell -ExecutionPolicy Bypass -File .\run-android.ps1 -AvdName "NOMBRE_AVD"
```

Opcional: saltar `flutter pub get`.

```powershell
powershell -ExecutionPolicy Bypass -File .\run-android.ps1 -SkipPubGet
```
