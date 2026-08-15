# First-time Flutter project setup

This repo ships the Dart source (`lib/`) and `pubspec.yaml`, but not the
generated native platform folders (`android/`, `ios/`) -- those are
machine/Flutter-SDK-version specific and are meant to be generated
locally, not committed.

One-time setup after cloning/transferring the project:

```
cd frontend
flutter create . --project-name civic_issue_app --org com.civicsystem
flutter pub get
```

This scaffolds `android/` (and `ios/`) without touching anything in
`lib/`. Then add these permissions to
`android/app/src/main/AndroidManifest.xml` inside the `<manifest>` tag
(above `<application>`):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

Then set `lib/config/api_config.dart` `baseUrl` to your backend address
and `flutter run`.
