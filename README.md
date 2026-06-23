<p align="center">
  <img src="https://flutter.dev/assets/flutter-logo.6ed04a8cd70b7aa540c6ec302a4e936c.svg" alt="Logo" width="200">
</p>

# Flutter core

**Example template** for bootstrapping Flutter projects with a ready-to-use basic setup. It includes the minimum structure, dependencies, and conventions to kick off a cross-platform app (**Android** and **iOS**) without starting from scratch.

Use this repository as a starting point: clone it, rename the package, and adapt the features to your product.

## What the template includes

- **Base architecture** — feature-based organization, GoRouter navigation, and Riverpod state management.
- **Environment configuration** — support for multiple environments (dev, staging, prod) and environment variables.
- **Preconfigured stack** — networking (Dio), local storage, internationalization, linting, and development tooling.
- **Sample screens** — minimal flows to validate the setup and serve as a reference when building new features.
- **Cross-platform builds** — project ready to compile for **Android** and **iOS**.

# 🛠️ Tech Stack

A detailed overview of the core technologies, libraries, and packages driving this project:

### ⚙️ Core & Engine

- **Framework:** Flutter `^3.44.2` (Dart SDK `^3.12.2`)
- **State Management:** Riverpod (`riverpod: ^3.2.1` & `flutter_riverpod: ^3.3.1`)
- **Routing & Navigation:** GoRouter (`go_router: ^17.2.1`)
- **Functional Programming:** Fpdart (`fpdart: ^1.2.0`)

### 🌐 Data & Storage

- **Networking:** Dio (`dio: ^5.9.2`)
- **Local Storage:** Shared Preferences (`shared_preferences: ^2.5.5`)
- **Internationalization:** Intl (`intl: ^0.20.2`)

### 🎨 UI & Media

- **Fonts & Icons:** Google Fonts (`google_fonts: ^6.2.1`), Cupertino Icons (`cupertino_icons: ^1.0.8`)
- **Modals & Toast:** Wolt Modal Sheet (`wolt_modal_sheet: ^0.11.0`), Fluttertoast (`fluttertoast: ^9.0.0`)
- **Video & Media:** Video Player (`video_player: ^2.10.1`), Chewie (`chewie: ^1.13.1`)

### 🧰 Utilities & Device Integration

- **Permissions:** Permission Handler (`permission_handler: ^12.0.1`)
- **Device Info:** Device Info Plus (`device_info_plus: ^12.4.0`)
- **Sharing & Saving:** Share Plus (`share_plus: ^12.0.2`), Gal (`gal: ^2.3.2`)
- **System Utilities:** Path Provider (`path_provider: ^2.1.5`), Collection (`collection: ^1.19.1`)

### 🛠️ Development & Quality Assurance

- **Linting & Analysis:** Riverpod Lint (`riverpod_lint: ^3.0.0-dev.4`), Flutter Lints (`flutter_lints: ^6.0.0`)
- **Assets & Setup:** Flutter Launcher Icons (`flutter_launcher_icons: ^0.14.4`), Flutter Native Splash (`flutter_native_splash: ^2.4.7`)
- **Testing:** Mocktail (`mocktail: ^1.0.5`)

# 🚀 Getting started

## Prerequisites

- **Flutter `3.44.1`** — install [FVM](https://fvm.app) and let it pick up the version pinned in `.fvmrc`. Otherwise install Flutter 3.35.2 manually and ensure `flutter --version` matches.
- **Dart `^3.12.2`** (bundled with the matching Flutter version).
- **Xcode** (latest stable) + **CocoaPods** for iOS builds.
- **Android Studio** / **Android SDK** (`min_sdk_android: 21`) for Android builds.
- A configured **AWS Amplify** environment (see `amplify/` and `lib/amplifyconfiguration.dart`).
- Firebase credentials per-platform (already wired in `lib/firebase_options.dart`).

### 1. Clone and select Flutter version

```bash
git clone <repository-url> flutter_core
cd flutter_core

# If you use FVM (recommended):
fvm install
fvm use
```

### 2. Configure environment

Copy `.env.example` and fill in the required secrets. Pre-existing per-environment files cover the typical flavors:

```bash
cp .env.example .env            # local development
# also available: .env.dev  .env.sandbox  .env.staging  .env.production
```

The build and run commands inject variables at compile-time via `--dart-define-from-file`. **Never commit real secrets.** `.env.example` is the source of truth for which keys exist; new variables must be added there and read through [environment.constant.dart](file:///Users/duvan/Programacion/flutter/flutter_core/lib/config/environments/environment.constant.dart).

### 3. Install dependencies

```bash
fvm flutter pub get        # or: flutter pub get
cd ios && pod install && cd ..
```

### 4. Generate code

Run `build_runner` whenever you add/modify Hive-annotated models or other generated artifacts:

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the app

```bash
fvm flutter run                       # default device
fvm flutter run -d <device-id>        # specific device
fvm flutter run --flavor <flavor>     # if a flavor is configured
```

### 6. Run tests & lints

```bash
fvm flutter test
fvm flutter analyze
```

### 7. Build release artifacts

Use the provided scripts in `tools/`:

```bash
./tools/build.sh                    # Android + iOS (default env)
./tools/build.sh staging            # specific environment
./tools/build.sh production --android-only
./tools/build.sh staging --ios-only
```

# 🌐 Flavors & Environments

The application supports multiple environments (flavors) to isolate development configurations, sandbox testing, staging builds, and live production environments. Each environment is configured using a matching dotenv (`.env`) file containing base URLs, API keys, and third-party service identifiers.

### 🧪 Available Environments

| Environment     | Flavor       | Dotenv File       | Description                                                                      |
| :-------------- | :----------- | :---------------- | :------------------------------------------------------------------------------- |
| **Development** | `dev`        | `.env.dev`        | Local development environment with logging and debug helpers enabled.            |
| **Sandbox**     | `sandbox`    | `.env.sandbox`    | Mocked or sandboxed API environment for integration checks and internal reviews. |
| **Staging**     | `staging`    | `.env.staging`    | Pre-production testing environment mirroring the production setup.               |
| **Production**  | `production` | `.env.production` | Live production release environment pointing to production servers.              |

### 🚀 Running the App with a Specific Flavor & Environment

To run the application targeting a specific environment, use the `--flavor` flag along with `--dart-define-from-file` to inject configuration variables at compile-time:

```bash
# Run in Development
fvm flutter run --flavor dev --dart-define-from-file=.env.dev

# Run in Staging
fvm flutter run --flavor staging --dart-define-from-file=.env.staging

# Run in Production
fvm flutter run --flavor production --dart-define-from-file=.env.production
```

### 📦 Building Release Artifacts per Flavor & Environment

Use the build commands to build binaries for specific environments, passing the corresponding `.env` configuration file:

```bash
# Android App Bundle (AAB) for Production
fvm flutter build appbundle --flavor production --dart-define-from-file=.env.production

# iOS IPA for Staging
fvm flutter build ipa --flavor staging --dart-define-from-file=.env.staging
```

> [!IMPORTANT]
> The active environment configurations are injected at compile-time. Never commit `.env` files containing production secrets or actual credentials to version control. Keep `.env.example` updated with the required variable keys.

# 🏗️ Architecture & Folder Structure

The project follows a modular [**MVVM (Model-View-ViewModel)**](https://docs.flutter.dev/app-architecture/guide) pattern with **Riverpod** for state management. Code is organized under `lib/` using feature-based vertical slicing to keep concerns separated, testable, and reusable.

### Project root

```text
flutter_core/
├── android/                 # Android native project and Gradle configuration
├── ios/                     # iOS native project and Xcode configuration
├── lib/                     # Application source code (see breakdown below)
├── test/                    # Unit and widget tests
├── tools/                   # Build helper scripts
│   ├── build.android.sh
│   ├── build.ios.sh
│   ├── build.sh
│   └── deploy.utils.sh
├── .github/                 # GitHub assets (README images, CI workflows)
├── .vscode/                 # VS Code / Cursor launch and editor settings
├── pubspec.yaml             # Dependencies and project metadata
├── analysis_options.yaml    # Static analysis and lint rules
├── .env.example             # Environment variable keys template
└── README.md
```

### `lib/` directory

```text
lib/
├── config/                  # App-wide configuration
│   ├── app/                 # App initialization and bootstrap setup
│   ├── constants/           # Global constants (dimensions, keys, assets)
│   ├── environments/        # Environment variables and flavor config
│   │   └── environment.constant.dart
│   ├── router/              # GoRouter setup and route definitions
│   │   ├── app_router.dart
│   │   └── app_routes.dart
│   └── theme/               # Design system and theme data
│       └── app_theme.dart
├── core/                    # Cross-cutting utilities (non-feature logic)
│   ├── helpers/             # Extension methods and helper classes
│   ├── localization/        # Multi-language / translation setup
│   ├── services/            # App-wide services (analytics, logging, etc.)
│   └── utils/               # Pure utilities (formatters, validators)
│       └── env_color_util.dart
├── data/                    # Data access layer
│   ├── exceptions/          # Custom exceptions and API error handling
│   ├── models/              # DTOs and domain models
│   ├── repositories/        # Repository implementations
│   └── services/            # Low-level data services (HTTP client, storage)
├── features/                # Feature modules (vertical slicing / MVVM)
│   ├── counter/             # Sample feature: Riverpod counter example
│   │   ├── providers/
│   │   │   └── counter_provider.dart
│   │   └── screens/
│   │       └── counter_page.dart
│   ├── home/                # Entry screen and environment diagnostics
│   │   ├── providers/
│   │   │   └── counter_provider.dart
│   │   └── screens/
│   │       └── environment_screen.dart
│   ├── login/               # Placeholder module (authentication)
│   └── settings/            # Placeholder module (app preferences)
├── shared/                  # Reusable code shared across features
│   ├── providers/           # Shared Riverpod providers
│   └── widgets/             # Reusable UI components
├── app.dart                 # Root MaterialApp.router setup
└── main.dart                # Application entry point
```

### Folder explanations

- **`config/`**: Defines how the app runs — routing (GoRouter), themes, global constants, and compile-time environment configuration.
- **`core/`**: Independent utilities and system integrations that support the app without owning feature-specific business logic or remote data access.
- **`data/`**: Data layer for remote APIs and local persistence. Holds models, repositories, services, and custom exceptions.
- **`features/`**: Vertical feature modules. Each folder groups its own screens, providers, and (optionally) models:
  - **`counter/`** — reference implementation using Riverpod for simple state management.
  - **`home/`** — initial route that displays the active environment and links to sample screens.
  - **`login/`** and **`settings/`** — scaffolded folders ready for new features.
  - Typical internal layout per feature:
    - **Model** — entities or data representations scoped to the feature.
    - **View** — widgets, pages, and UI components (`screens/`, `widgets/`).
    - **ViewModel / State** — Riverpod providers that hold state and drive UI updates (`providers/`).
- **`shared/`**: Cross-feature widgets and providers reused by multiple modules.
- **`main.dart` & `app.dart`**: Bootstrap the app — `main.dart` initializes Riverpod; `app.dart` wires theme, router, and environment config.

# 📝 Development Conventions

Follow these naming and styling conventions when contributing to the codebase:

### 📂 File Naming Conventions

All source files must use `snake_case` and include the appropriate suffix corresponding to their architectural role:

- **Views / Screens**: Use the `_screen.dart` suffix for screen-level widgets (e.g., `login_screen.dart`). Regular/reusable widgets do not require a suffix.
- **Repositories**: Use the `_repository.dart` suffix (e.g., `jobs_repository.dart`).
- **Services**: Use the `_service.dart` suffix (e.g., `auth_service.dart`).
- **Routers**: Use the `_router.dart` suffix (e.g., `app_router.dart`).
- **Themes**: Use the `_theme.dart` suffix (e.g., `app_theme.dart`).
- **Utilities**: Use the `_util.dart` suffix for pure, stateless functions (e.g., `date_formatter_util.dart`).
- **Helpers**: Use the `_helper.dart` suffix for functions containing state or interacting with the `BuildContext` (e.g., `dialog_helper.dart`).
- **Models**: Use the `_model.dart` suffix for data transfer objects (DTOs) and API models (e.g., `user_model.dart`).
- **Providers**: Use the `_provider.dart` suffix for view logic and state providers (e.g., `profile_provider.dart`).

### 🏷️ Code Naming Conventions

- **Classes, Mixins, Enums & Extensions**: Always use `UpperCamelCase` (PascalCase) (e.g., `LoginScreen`, `UserModel`, `AppTheme`).
- **Interfaces & Abstract Classes**: Use `UpperCamelCase`.
  - For standard abstract classes, append the `Impl` suffix to their implementations (e.g., abstract class `JobsRepository` and implementation `JobsRepositoryImpl`).
  - When using the `interface` modifier keyword instead of an abstract class, prefix the interface name with a capital `I` (e.g., `interface class IJobsRepository`).
- **Variables, Parameters & Functions**: Always use `lowerCamelCase` in all scenarios (e.g., `jobList`, `fetchData`, `userId`).

# 🧪 Testing & Linting

Ensure your code passes static analysis and tests before opening a Pull Request.

## Run Static Analysis

```bash
flutter analyze
flutter test
flutter test --coverage
```

# 📄 License

This template is **free to use** for personal and commercial projects. You may copy, modify, and distribute it without restriction.
