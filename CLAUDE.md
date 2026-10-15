# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Cek Reklame Mobile" / Bapenda Internal: an internal Android app for Bapenda Kota Surabaya (the city revenue agency). Officers check registered billboards using camera photos and geolocation, run new-billboard surveys, and handle tax payments through VA/QRIS. The Dart package name is `bapendacore`, so imports look like `package:bapendacore/...`. UI strings, comments, and failure messages are in Indonesian, so keep new ones in Indonesian too.

## Commands

The Flutter version is pinned through FVM (`.fvmrc` → 3.38.1). Prefix commands with `fvm` if you use it. CI (`.github/workflows/main.yml`) builds with Flutter 3.35.4.

```sh
flutter pub get
flutter run
flutter analyze                       # lints: package:flutter_lints/flutter.yaml
dart format lib
flutter test                          # all tests
flutter test test/widget_test.dart    # single file
flutter test --plain-name "name"      # single test by name
flutter build apk --release           # what CI ships (on GitHub release publish)
dart run build_runner build --delete-conflicting-outputs   # regenerate code
```

`test/widget_test.dart` is still the stock counter template. It does not match the app and will fail.

### Code generation

Generated files are committed. Re-run `build_runner` after changing any of these:
- `@injectable` / `@lazySingleton` / `@LazySingleton(as: ...)` / `@module` annotations → `lib/core/di/injection.config.dart`
- `@JsonSerializable` models → `*.g.dart`
- `@freezed` states (e.g. `camera_state.dart`, `home_state.dart`) → `*.freezed.dart`
- `.env` values used by `EnvConfig` (envied) → `lib/core/network/env_config/env_config.g.dart`

### Environment

The app needs a `.env` at the repo root (template: `.env.example`; keys `BASE_URL`, `GOOGLE_MAPS_API_KEY`, `APP_SIGN_STAGING`). It is read two ways:
1. `flutter_dotenv` loads it at runtime (`.env` is listed as an asset in `pubspec.yaml`).
2. `envied` compiles it into `EnvConfig` (obfuscated) at build_runner time. Changing `.env` therefore requires regenerating `env_config.g.dart`.

## Architecture

The app uses Clean Architecture with three layers under `lib/`, plus shared infrastructure:

- `domain/`: entities, repository interfaces, and use cases (`@lazySingleton` classes that wrap repository calls).
- `data/`: remote datasources (abstract class + `@LazySingleton(as: ...)` impl using the injected `Dio`), JSON models with `toEntity()`, and repository impls.
- `presentation/features/<feature>/`: `cubit/`, `pages/` or `screens/`, and `widgets/`. Cross-feature widgets live in `presentation/shared/`.
- `core/`: DI, networking, error types, storage, services, utils, and design tokens (`core/constants/design_system/tokens/`).
- `routes/`: `AppRoutes` (path constants) and `AppRouter.router` (GoRouter).

### Dependency injection

The app uses `get_it` + `injectable`. `getIt` and `configureDependencies()` live in `core/di/injection.dart`. Third-party singletons (SharedPreferences via `@preResolve`, FlutterSecureStorage, Connectivity, Dio) are provided in `core/di/register_module.dart`. Cubits are registered in DI too:
- `AuthCubit` is a `@lazySingleton`. `main.dart` provides it globally, and the router also reads it from `getIt` for redirects.
- Feature cubits are factories, created in route builders with `BlocProvider(create: (_) => getIt<XCubit>()..init())`.

### Networking (`core/network/`, `register_module.dart`)

A single `Dio` instance carries several pieces of custom behavior:
- A custom `HttpClient.connectionFactory` resolves hosts through DNS-over-HTTPS (`ResilientDnsResolver`) to bypass carrier DNS. It also accepts bad TLS certificates, but only for the base URL host and the allowlisted hosts (`apibapenda.surabaya.go.id`, `drivebapenda.surabaya.go.id`).
- Interceptor order: `ConnectivityCheckInterceptor` → `RetryInterceptor` (3 retries; `FormData` uploads only retry on connection errors, to avoid duplicate submissions) → `DioAuthInterceptor` (Bearer token from secure storage; on 401 it refreshes the token or forces logout via `AppRouter`) → `ChuckerDioInterceptor` in debug builds only.
- API responses are wrapped in `BaseApiResponseModel<T>`. Datasources check `isSuccess` and throw when it is false.
- Error flow: datasources throw `DioException`/`AppException`. `executeSafeApiCall` (`safe_api_call.dart`) maps them through `DioErrorHandler` into `Either<Failure, T>` (dartz), using the `Failure` subclasses in `core/errors/failure.dart`. Not every repository uses this yet; auth, for example, returns plain futures and the cubit catches the errors.

### Routing & auth

`AppRouter.router` uses `refreshListenable: GoRouterRefreshStream(getIt<AuthCubit>().stream)` together with a global `redirect`. Unauthenticated users are sent to `login` unless the route is in `_publicRoutes` (splash, onboarding, login), and authenticated users are redirected away from login and onboarding. New public routes must be added to `_publicRoutes`. Session data (token, NIP, cached user profile JSON, must-change-password flag) lives in `AppSecureStorage`.

### Light/dark theme

Everything is exported from `core/theme/theme_kit.dart`. Dark mode is **scoped**, not global: wrap a route's page in `AdaptiveThemeScope`, and use `context.palette` (`AppPalette`, a `ThemeExtension`) for colors in place of hardcoded `AppThemeColors`. Older pages still hardcode light colors and would break under a global dark theme. Read or change the mode with `context.isDarkMode` / `context.toggleThemeMode()` / `AppThemeUtils`. `ThemeModeCubit` stores the choice per user in `AppPreferences` (key `theme_mode_<nip>`, with a guest key before login). `main.dart` re-syncs it whenever `AuthCubit` changes state.

### In-progress modules

- `va_qris` is wired to `CekReklameApi`'s `/api/pembayaran/*` (`jenis-pajak`, `tagihan`, `bayar`, `status`). Ordering lives in the API: unpaid masa come oldest first and `bayar` rejects a non-sequential selection, so the client never sorts. `PeriodSelectionLogic` only drives the checkbox UI. The flow still passes data between routes via `extra`, and each route builds its own `VaQrisCubit` (Freezed state) seeded from that `extra`: `init()`, then `loadBilling(billing)`, then `startSession(session)`, which polls `status` every 5 s until lunas or expired.
- `survey_baru` and the `survey_permohonan_baru` folders contain `readme.md` placeholders.

## Conventions (from README)

- Conventional Commits: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, with an optional scope, e.g. `feat(api): ...`.
- Branch prefixes: `feature/`, `bugfix/`, `refactor/`, `docs/`. PRs target `master`.
- Android native requirements: the UCrop activity must be declared in `AndroidManifest.xml`. If the build fails with `Inconsistent JVM-target compatibility`, align `compileOptions` and `kotlinOptions` in `android/app/build.gradle.kts`.
