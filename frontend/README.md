# Civic Issue App (Flutter)

Frontend for the AI-Based Civic Issue Detection, Prioritization and
Automated Reporting System.

## Configure the backend URL

Edit `lib/config/api_config.dart` and set `baseUrl` to wherever the
Django backend is reachable from your device/emulator:

- Android emulator talking to Docker on the same machine: `http://10.0.2.2:8000`
- Physical device on the same Wi-Fi as your machine: `http://<your-lan-ip>:8000`

## Run

```
flutter pub get
flutter run
```

## Required Android permissions

Already declared in `android/app/src/main/AndroidManifest.xml` (once you
generate the Android folder with `flutter create .`):
`INTERNET`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`,
`CAMERA`, `READ_MEDIA_IMAGES`.
