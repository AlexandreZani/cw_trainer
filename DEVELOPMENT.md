## Setting Up Your Dev Environment

### Setting up with Nix (recommended)

The recommended way to get a working development environment is via [Nix](https://nixos.org/) using the provided flake, which
pins Flutter, the Android SDK, and the JDK to known-good versions. This takes care of all pre-requisites for Android development.

First, [install Nix](https://nixos.org/download/) and follow the instructions for the multi-user or single-user installation.

You will then need to enable nix flakes. This allows to pin the various development tools to a known-good version.

If you opted for a single-user installation, you will need to edit `~/.config/nix/nix.conf`. Otherwise, edit `/etc/nix/nix.conf`.

Add the following line to enable flakes.
```
experimental-features = nix-command flakes

```

#### To enter the dev shell

```sh
cd cw_trainer
nix develop
```

This drops you into a shell with `flutter`, the Android SDK (`ANDROID_HOME`), and `JAVA_HOME` all set correctly.

#### Direnv (optional)

You can install [direnv](https://direnv.net/) to avoid having to manually enter the dev shell.

```sh
cd cw_trainer
direnv allow # only needed the first time.
```

### Prerequisites

If you want to install the prerequisites manually, you will need
* [Dart](https://dart.dev/get-dart) version 3.8.0 (stable).
* The [Flutter SDK](https://docs.flutter.dev/install) version 3.32.0.

To develop for Android you will also need
* The [Android SDK](https://developer.android.com/tools/releases/platform-tools) version 34.0.0.
* The [Android NDK](https://developer.android.com/ndk/downloadss) version 27.0.12077973.
* A [JDK](https://openjdk.org/projects/jdk/17/) version 17.

## Install Flutter dependencies

```sh
flutter pub get
```

## Build a debug APK

```sh
flutter build apk --debug
```

The output lands at `build/app/outputs/flutter-apk/app-debug.apk`.

## Run on a device or emulator

### Physical device

Enable USB debugging on your Android device, plug it in, then:

```sh
flutter devices        # confirm your device appears
flutter run
```

### Emulator (first-time setup)

The dev shell provides two helper scripts:

```sh
emulator-setup    # creates an AVD named emulator-5554 (Pixel 9 Pro XL, Android 35, x86_64)
emulator-launch   # starts the emulator
```

After the emulator boots, `flutter run` will target it automatically.

> **Note:** The emulator uses hardware GPU acceleration (`hw.gpu.mode=host`). On NixOS/Linux this requires the `QT_QPA_PLATFORM=xcb` and `LD_LIBRARY_PATH` variables that are already set by the dev shell.

## Run tests

```sh
flutter test
```

## Build a signed release AAB (Play Store)

Signing keys are encrypted with [agenix](https://github.com/ryantm/agenix) and require an SSH identity at `~/.ssh/desktop` or `~/.ssh/laptop`. If you have the appropriate key, run:

```sh
build-aab
```

This decrypts `secrets/android-signing.tar.age`, builds the app bundle, and cleans up the key material. The output is at `build/app/outputs/bundle/release/app-release.aab`.

## CI

The GitHub Actions workflow (`.github/workflows/android-build.yml`) builds a debug APK on every push/PR to `main` using the `subosito/flutter-action` action (Flutter stable channel). It does not require any secrets.
