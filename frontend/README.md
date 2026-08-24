# Civic Operations Center (Flutter web)

Web application for **department admins** and **super admins**.

Citizens report issues in `civic_mobile/`. This app is the operations console.

## Configure the backend

Default API host:

- Web / Windows: `http://127.0.0.1:8000`
- Android emulator: `http://10.0.2.2:8000`

Override:

```
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## First-time platform folders

```
cd frontend
flutter create . --project-name civic_issue_app --org com.civicsystem --platforms=web,windows
flutter pub get
```

## Run

Start Django (Docker on port 8000), then:

```
flutter run -d chrome
```

Sign in with a `dept_admin` or `super_admin` account (see `seed_departments`).
