# Tilawa Android App

The Android native shell for Tilawa, built with **Jetpack Compose** and Material 3. Consumes the KMP `:shared` core directly as a Kotlin/JVM module dependency.

## Prerequisites

- **JDK**: Java 17 or higher
- **Android SDK**: Compile SDK `37`, Minimum SDK `30`
- **Gradle**: Uses the repository's Gradle Wrapper (`./gradlew`)

---

## Building and Running

### 1. Build Debug APK
```bash
./gradlew :androidApp:assembleDebug
```
The APK will be generated at `androidApp/build/outputs/apk/debug/androidApp-debug.apk`.

### 2. Install and Run on Connected Device / Emulator
Make sure an Android emulator is running or a physical device is connected via ADB (`adb devices`), then run:
```bash
./gradlew :androidApp:installDebug
```

### 3. Run Unit Tests
```bash
./gradlew :androidApp:test
```

### 4. Run Instrumented UI Tests
```bash
./gradlew :androidApp:connectedAndroidTest
```
