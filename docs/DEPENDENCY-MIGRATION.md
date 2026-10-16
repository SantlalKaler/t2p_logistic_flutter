# Dependency migration — 2026-10-16

SDK: FVM Flutter 3.47.7 / Dart 3.13.5.

20 application dependencies and flutter_lints were updated. Packages already on their latest release remain unchanged. Four historical dependency overrides were removed. Transitive dependencies were upgraded through normal Pub resolution; the lockfile records the reproducible graph.

## Implementation changes

- connectivity_plus 7.3.1: consume lists of connection types, check the initial connection and refresh on app resume, cancel the stream on disposal, and prevent a stale initial query from overwriting a newer event. Existing controller state and snackbar behavior remain available.
- country_flags 4.1.2: use ImageTheme and RoundedRectangle in the login phone field.
- geocoding 5.0.0: use a lazily initialized Geocoding instance for forward and reverse lookup. Lazy creation avoids initializing an unsupported platform implementation at app startup.
- dio 5.11.1: use DioException. Existing URLs, payloads, authorization and response handling are preserved.
- permission_handler 13.0.2: use the permission request result, rather than relying on Android status queries to identify permanent denial.
- Firebase database 13.0.0 and Firestore 7.0.0: update together to share firebase_core 5.0.0. Existing DatabaseReference/ref/set usage remains valid. The project currently has no Firestore calls; its pre-existing commented Firebase startup was not enabled as part of this dependency migration.
- Font Awesome 11: the repository has no active FontAwesomeIcons/FaIcon call sites to migrate.
- Other direct-package usages were checked against updated APIs by static analysis and Android compilation.

## Platform configuration

- AGP 9.1.1, Gradle 9.3.1; Android compile SDK 37, needed by permission_handler 13. Target and minimum Android SDK continue to follow Flutter defaults.
- Native AGP Kotlin is enabled. App compiler options use the Kotlin compilerOptions DSL and JVM 17.
- Android plugin modules are configured from the root Gradle project, with matching JVM targets and a compile SDK at least equal to the application SDK. SDK parsing accepts Android's 37.0 representation.
- Gradle heap is 4 GB with two workers. Jetifier is disabled because the upgraded Android dependencies use AndroidX; this also avoids memory-heavy transformations of Flutter engine archives.
- Kotlin incremental compilation remains disabled for the project's cross-drive Windows Pub cache layout.
- iOS deployment target raised to 15.0 and macOS to 11.0 for current Firebase/platform requirements. Apple builds require macOS/Xcode and were not run on this Windows host. Google Maps still uses its default iOS implementation; adopting a newer optional iOS SDK implementation is a separate platform choice.

## Version constraints

connectivity_plus 7.3.2 requires nm 0.6 / dbus 0.8, while the latest geolocator Linux implementation requires dbus 0.7. connectivity_plus 7.3.1 is the latest jointly resolvable release. No dependency override is used to force incompatible versions.

The remaining newer packages in dependency-outdated.json are constrained by parent-package requirements or Flutter SDK pins: connectivity_plus, cross_file, dbus, gsettings, material_color_utilities, nm, qr, and test_api.

## Verification

- Four connectivity regression tests cover initial state/multiple networks, resume refresh, initial-query races and subscription disposal.
- Static analysis checks compiler compatibility. Existing project lint/deprecation findings remain; flutter_lints 6 reports additional pre-existing style findings.
- Android debug APK build passed with exit code 0. Artifact: build/app/outputs/flutter-apk/app-debug.apk (179.8 MB). Full output is recorded in migration-build.log.
- The current Flutter build may still emit a future Kotlin migration warning for the latest Firebase plugin scripts, which retain conditional support for older AGP versions. App native Kotlin migration is complete.
- No live backend writes, OTP sends or authenticated user workflows were exercised. Tests cover local connectivity lifecycle behavior, not external API/provider availability.

## Migration references

- https://pub.dev/packages/connectivity_plus/changelog
- https://pub.dev/packages/country_flags/changelog
- https://pub.dev/packages/geocoding/changelog
- https://pub.dev/packages/permission_handler/changelog
- https://pub.dev/packages/cloud_firestore/changelog
- https://pub.dev/packages/firebase_database/changelog
- https://pub.dev/packages/font_awesome_flutter/changelog
- https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers
