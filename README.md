# T2P Logistic

## Flutter SDK

This project uses FVM with Flutter **3.47.7** (Dart **3.13.5**).
Install FVM, then run from the project root:

```sh
fvm install
fvm flutter pub get
fvm flutter run
```

Use `fvm flutter` for all Flutter commands. In Android Studio, set the Flutter SDK path to `<project>/.fvm/flutter_sdk`. VS Code uses the checked-in workspace SDK setting.

## Android build

The Android toolchain follows the Flutter 3.47.7 template: Gradle **9.3.1**, Android Gradle Plugin **9.1.1**, Kotlin Gradle Plugin **2.4.0**, and Java 17 source/target compatibility. Use JDK 17 or newer supported by Gradle (the verified build uses Android Studio's JDK 21). Compile SDK is 37 (required by permission_handler 13); target/min SDK and NDK follow the pinned Flutter SDK.

```sh
fvm flutter build apk --debug
```


The debug APK is generated at `build/app/outputs/flutter-apk/app-debug.apk`.

Kotlin incremental compilation is disabled because Windows installations may keep the Pub cache on C: and this project on D:, which otherwise causes Kotlin cache path errors. AGP built-in Kotlin is enabled; the app no longer applies the legacy Kotlin Android plugin.



delivery partner number 
8420340488
