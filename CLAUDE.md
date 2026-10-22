# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Cek Reklame Mobile" / MyBapenda: an internal Android app for Bapenda Kota Surabaya (the city revenue agency). Modules include billboard checks with camera + geolocation (`cek_reklame`, `camera`), new-billboard surveys (`survey_baru`), employee attendance (`absensi`, `laporan_kehadiran`), Balai RW duty reports (`balai_rw`), field tasks (`my_task`), and tax payment via VA/QRIS (`va_qris`). The Dart package name is `mybapenda`, so imports look like `package:mybapenda/...`. UI strings, comments, log messages, failure messages, and domain names (`tanggalAwal`, `hanyaAktif`, `pertanyaan`, ...) are in Indonesian. Keep new ones in Indonesian too.

## Commands

The Flutter version is pinned through FVM (`.fvmrc` → 3.38.1). Prefix commands with `fvm` if you use it. CI (`.github/workflows/main.yml`) builds with Flutter 3.35.4 and Java 17, so avoid APIs newer than 3.35.

```sh
flutter pub get
flutter run
flutter analyze                       # lints: package:flutter_lints/flutter.yaml (no custom rules)
dart format lib
flutter test                          # all tests
flutter test test/absensi/absen_cubit_test.dart   # single file
flutter test --plain-name "name"      # single test by name
flutter build apk --release           # what CI ships (only on GitHub release publish)
dart run build_runner build --delete-conflicting-outputs   # regenerate code
```

`test/widget_test.dart` is still the stock counter template. It does not match the app and will fail. The real tests are in `test/absensi/`. They use hand-written fakes (`class _FakeRepository implements AbsensiRepository`, a fake Dio `HttpClientAdapter`); the project has no mockito or mocktail. Follow that pattern.

### Code generation (watch the gitignore)

Re-run `build_runner` after changing any of these:
- `@injectable` / `@lazySingleton` / `@LazySingleton(as: ...)` / `@module` → `lib/core/di/injection.config.dart`
- `@JsonSerializable` models → `*.g.dart`
- `@freezed` states (only `camera_state.dart` and `home_state.dart`) → `*.freezed.dart`
- `EnvConfig` (envied) → `lib/core/network/env_config/env_config.g.dart`

**`.gitignore` ignores `*.g.dart`, `*.freezed.dart`, and `*.config.dart`, but those generated files are committed anyway (force-added).** CI does not run `build_runner`. A NEW generated file therefore has to be added with `git add -f <file>`, or the CI build breaks. Files that are already tracked are picked up automatically when they change.

### Environment

`.env` at the repo root (template `.env.example`; keys `BASE_URL`, `GOOGLE_MAPS_API_KEY`, `APP_SECRET_KEY`, `APP_SIGN_STAGING`). CI writes it from the `ENV_FILE` secret. It is read two ways:
1. `flutter_dotenv` at runtime (`.env` is an asset in `pubspec.yaml`). `APP_SECRET_KEY` (HMAC) is read this way on purpose, so that `env_config.g.dart` doesn't need regenerating.
2. `envied` → `EnvConfig` (obfuscated, compiled at build_runner time). `BASE_URL` comes from here. Changing these values requires regenerating `env_config.g.dart`.

## Architecture

Clean Architecture under `lib/`: `domain/` ← `data/` ← `presentation/`, plus `core/` and `routes/`. Each feature uses the same subfolder name in every layer (e.g. `balai_rw/` in datasources, models, repositories, entities, usecases, features).

### Reference pattern for a new feature (copy `balai_rw` / `absensi`; these are the newest and the cleanest)

1. **Endpoint**: add a constant to `core/network/api_endpoints.dart` (grouped per module with a `// ====` comment header). Never hardcode a path in a datasource.
2. **Entity** (`domain/entities/<fitur>/`): a plain class `extends Equatable`, `const` constructor, every field in `props`. No JSON.
3. **Model** (`data/models/<fitur>/`): `@JsonSerializable()` with an explicit `@JsonKey(name: ...)` on each field, `fromJson`/`toJson`, plus an extension `XxxModelX on XxxModel { XxxEntity toEntity() }` in the same file. Request payloads (multipart) are plain classes with `Future<FormData> toFormData()`, plus an extension `XxxEntityX on XxxEntity { toModel() }`.
4. **Datasource** (`data/datasources/<fitur>/`): `abstract class IXxxRemoteDataSource` + `@LazySingleton(as: IXxxRemoteDataSource) class XxxRemoteDataSourceImpl` in one file, injected with `Dio`. Parse with `BaseApiResponseModel<T>.fromJson(response.data, (json) => ...)`; if `!isSuccess`, `throw ServerException(base.status, base.errorMessage)`. Return the model (`data ?? []` for lists).
5. **Repository interface** (`domain/repositories/<fitur>/i_xxx_repository.dart`): `abstract class IXxxRepository`, methods return `Future<Either<Failure, T>>` (dartz).
6. **Repository impl** (`data/repositories/<fitur>/`): `@LazySingleton(as: IXxxRepository)`, every method wrapped in `executeSafeApiCall(() async { ... model.toEntity() })`.
7. **UseCase** (`domain/usecases/<fitur>/`): ONE `@lazySingleton class XxxUseCase` per feature with many pass-through methods to the repository (not one class per action).
8. **Cubit** (`presentation/features/<fitur>/cubit/`): see below.
9. **Route**: a constant in `AppRoutes` (kebab-case path) and a `GoRoute` in `AppRouter` with `path` and `name` both set to the same constant.
10. Run `build_runner`, then `git add -f` any new generated files.

Older code (auth, history, geocoding) is inconsistent: no `I` prefix (`AuthRepository`), plain futures without `Either`. Don't copy it for new modules. New code uses the `I` prefix for interfaces.

### Cubits & state

- Feature cubits: **`@injectable`** (a factory), NEVER `@lazySingleton`. A singleton cubit gets closed when its page pops and then crashes when the page is reopened. Only app-global cubits are `@lazySingleton`: `AuthCubit`, `ThemeModeCubit`, `NetworkCubit`.
- Cubits are created in the route builder: `BlocProvider(create: (_) => getIt<XCubit>()..load())` (or `MultiBlocProvider`). They are not created inside the page.
- The cubit depends on a **UseCase**, not on a repository or datasource.
- States use `Equatable`. Two styles are accepted: `sealed class XState extends Equatable` with subclasses (`AbsenState`, `LaporanState`), or a single class with a `XStatus` enum + `copyWith` (`BalaiRwHubState`). Freezed is only used by the older camera/home states, so don't add new Freezed states.
- After every `await`, check `if (isClosed) return;` before calling `emit`.
- Failure handling: `result.fold((f) => emit(XFailure(f.message)), (data) => ...)`. `Failure.message` is already a user-friendly message in Indonesian.
- Logic that isn't state (DevOps review): business rules go in the domain. Rules about one entity become a getter/method on that entity (e.g. `BerkasEntity.sla(now)`, `perluPerhatian`); rules that decide an action (required fields, validation) go in the feature UseCase (e.g. `PengirimanUseCase.validasiSerah`). Display-only helpers (tab grouping, labels, view data, map projection) go in `features/<fitur>/utils/` with the `_ui_helper.dart` suffix (e.g. `pantau_ui_helper.dart`). The pengiriman module follows this; older modules still have a `logic/` folder (`rekap_harian_logic.dart`, `period_selection_logic.dart`) and should migrate when touched.

### Errors

`core/errors/exception.dart` (`AppException` subclasses, thrown by the data layer) and `core/errors/failure.dart` (`Failure` subclasses, returned to presentation) mirror each other one-to-one with Indonesian default messages. `executeSafeApiCall` maps `DioException` → `DioErrorHandler` → `AppException` → `Failure`. Watch out: `_mapExceptionToFailure` only maps `Server`/`Unauthorized`/`Timeout`/`NoInternet` exceptions. Any other `AppException` becomes `UnknownFailure`, so extend the mapping if you throw a new type.

### Networking (`core/di/register_module.dart`)

A single `Dio` instance (timeouts: connect 25s / receive 30s / send 45s):
- Its `HttpClient.connectionFactory` resolves DNS through DoH (`ResilientDnsResolver`) to bypass carrier DNS. Bad TLS certificates are accepted ONLY for the `BASE_URL` host plus `apibapenda.surabaya.go.id` and `drivebapenda.surabaya.go.id`.
- Interceptor order: `ConnectivityCheckInterceptor` → `RetryInterceptor` (3x; a `FormData` request is only retried on `connectionError`, to avoid duplicate submissions) → `HmacKantorInterceptor` (adds `X-App-*` headers ONLY for paths that start with `/api/kantor/`; it must come after Retry so the signature is recomputed) → `DioAuthInterceptor` (Bearer token; a 401 triggers refresh or a forced logout) → `ChuckerDioInterceptor` (debug builds only).
- New absensi/kantor endpoints MUST use the `/api/kantor/` prefix (`ApiEndpoints.kantorPrefix`) so they get signed.

### Routing & auth

`AppRouter.router` uses `refreshListenable: GoRouterRefreshStream(getIt<AuthCubit>().stream)` + a global `redirect`. Routes outside `_publicRoutes` (splash, onboarding, login) require login, so new public routes have to be added there. Arguments go through `state.extra`. For multiple arguments, use a Dart record (`state.extra as ({String nomor, ...})`). For a single entity argument, use a type check with a fallback page (`extra is TaskEntity ? Page(task: extra) : const DashboardPage()`), because `extra` is lost on deep link / restore. Session data (token, NIP, profile JSON, must-change-password flag) lives in `AppSecureStorage`. Simple preferences go in `AppPreferences`.

### Theme & colors

- The color actually in use is `AppThemeColors` from **`core/constants/app_colors_new.dart`**. `core/constants/design_system/tokens/app_colors.dart` declares a duplicate `AppThemeColors` that nobody imports. Don't import it, or you'll get a name conflict. `AppSpacing`/`AppRadius`/`AppTypography`/`AppShadows` exist but are unused by pages so far. The font is Poppins (set globally).
- Dark mode is **scoped, not global**: wrap a page in `AdaptiveThemeScope` in the route builder, and use `context.palette` (`AppPalette`) for colors instead of `AppThemeColors`. Pages that already support it: Home, Absensi, Laporan Kehadiran. Older pages hardcode light colors and would break under a global dark theme. Import everything through `core/theme/theme_kit.dart`. `ThemeModeCubit` stores the choice per user (`theme_mode_<nip>`) and is re-synced from `main.dart` whenever `AuthCubit` changes state.

### Mandatory utilities (the "Aturan Ketat" headers in the files)

- Logging: use `AppLogger.info/debug/warning/error` (`core/utils/app_logger.dart`). **Never `print()`**, and don't call Crashlytics directly. Critical errors go through `AppLogger.error(msg, e, stackTrace)`.
- File/photo picking: always `AppFilePickerUtils` (it handles compression, HEIC conversion, and validation). Don't call `image_picker`/`file_picker` directly, and don't call `AppImageCompressUtils` from UI/Cubit. To shrink a photo before an upload (avoiding 413 errors), use `BtImageCompressor.toJpeg` (`presentation/shared/widgets/bt_image_compressor.dart`).
- `AppFileOpenerUtils` opens files in an EXTERNAL app, so it is only for templates/downloads. In-app previews use `ImagePreview.openFullScreen` / the in-app PDF viewer.
- Rupiah/NOP formatting: `AppFormatters` (`core/utils/app_formatters_utils.dart`). Indonesian dates: `core/utils/date_format_id.dart` / `presentation/shared/utils/date_util.dart`.
- Before writing a new widget, check `presentation/shared/widgets/` (button, form_fields, status_chip, step_indicator, custom_modal_widget, ...).

### Modules still on mock data

- `va_qris`: mock data (`va_qris/mock/`) + `setState`. `va_qris/cubit_blueprint/va_qris_cubit_blueprint.dart` is the specification for the target Cubit/Freezed state/use cases. Follow it when wiring.
- `my_task`: still uses `my_task/mock/`.
- `survey_baru`: the screens still pass data as `Map<String, dynamic>`. The data/domain layer for Survey Permohonan (`ISurveyPermohonanRepository`, `SurveyPermohonanUseCase`) is ready, but no cubit uses it yet (the `cek_reklame/cubit|screens/survey_permohonan_baru/readme.md` placeholders are empty).

## Git workflow

- Develop on your own branch (e.g. `najib-dev`, `dev_william`). PRs go into **`development`**, which is then promoted to `master`. Only `@williamjohan` can approve (`.github/CODEOWNERS`).
- PR titles / squash commits currently use the format `[FEAT]: ...` / `[FIX]: ...`. Regular commits follow the README's Conventional Commits (`feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, optional scope: `fix(core): ...`).
- Android native: the UCrop activity must be declared in `AndroidManifest.xml`. If the build fails with `Inconsistent JVM-target compatibility`, align `compileOptions` and `kotlinOptions` in `android/app/build.gradle.kts`.
