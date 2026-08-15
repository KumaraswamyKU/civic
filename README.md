# AI-Based Civic Issue Detection, Prioritization and Automated Reporting System

Final year B.Tech CSE project (VTU). Citizens report civic issues (garbage
accumulation, faulty streetlights, water leakage) by photo + GPS location
from a Flutter Android app; a CNN model classifies the issue; the system
auto-assigns priority and routes it to the right department (Garbage /
Water / Electrical), each with its own admin login and analytics
dashboard.

## Project layout

```
civic-issue-system/
├── backend/                 Django REST API
│   ├── config/               Django project settings/urls
│   ├── apps/
│   │   ├── accounts/          Custom user model, signup/login (email or phone)
│   │   ├── departments/       Garbage / Water / Electrical departments + seed command
│   │   ├── complaints/        Complaint model, image+GPS upload, status workflow
│   │   ├── ml/                CNN inference (fallback-safe) + train.py
│   │   └── reports/           Dashboard summary + CSV export
│   ├── dataset/               <- put your Kaggle dataset here (see dataset/README.md)
│   ├── ml_models/             <- trained model weights land here after training
│   ├── Dockerfile / entrypoint.sh
│   └── requirements.txt
├── frontend/                 Flutter Android app
│   ├── lib/
│   │   ├── config/            API base URL
│   │   ├── models/            User, Complaint
│   │   ├── services/          Auth, GPS, API calls
│   │   ├── screens/           Signup, Login, Home/report list, Upload, Admin dashboard
│   │   └── widgets/
│   └── SETUP.md               One-time `flutter create .` step (native folders aren't committed)
├── docker-compose.yml         Postgres + Django backend
├── .env.example                All config lives here, nothing hardcoded
└── .gitignore
```

## Why nothing should "mismatch" when you move the project

- Every environment-specific value (DB credentials, secret key, allowed
  hosts, ML model path, CORS) is read from `.env` via `django-environ` --
  never hardcoded in code. Copy `.env.example` to `.env` on the new
  machine and adjust values; the code doesn't change.
- The backend Dockerfile installs exact pinned versions from
  `requirements.txt`, so the Python environment is identical everywhere
  Docker runs.
- Postgres data, uploaded images (`media/`), and static files are Docker
  **named volumes**, so they survive container rebuilds and aren't tied
  to a host path.
- The dataset and trained model files are intentionally kept **outside**
  git (see `.gitignore`) since they're large/binary and machine-specific
  to fetch -- only their expected folder structure is tracked. The
  backend still runs correctly without them (see ML fallback mode below).
- The Flutter `android/`/`ios/` folders are also not committed (Flutter
  regenerates them per-SDK-version via `flutter create .` -- see
  `frontend/SETUP.md`), which avoids native build mismatches across
  machines.

## Quick start (backend)

```bash
cp .env.example .env      # edit values, especially POSTGRES_PASSWORD and DJANGO_SECRET_KEY
docker compose up --build
```

This will:
1. Start Postgres.
2. Build and start Django, waiting for the DB, running migrations,
   collecting static files, and auto-creating the 3 departments plus one
   admin account per department (see `apps/departments/management/commands/seed_departments.py`
   for the default credentials -- **change these passwords after first login**).
3. Serve the API at `http://localhost:8000`.

Create a superuser (for the Django admin site at `/admin/`) if you want one:
```bash
docker compose exec backend python manage.py createsuperuser
```

## Quick start (frontend)

See `frontend/SETUP.md` for the one-time `flutter create .` step, then:
```bash
cd frontend
flutter pub get
flutter run
```
Set `lib/config/api_config.dart` `baseUrl` to reach your backend (Android
emulator: `http://10.0.2.2:8000`; physical device: your machine's LAN IP).

## Training the CNN model

The API works immediately without a trained model -- complaints are
still created, just tagged `issue_type = "unknown"` (see
`backend/apps/ml/inference.py`). Once you've downloaded your dataset
from Kaggle:

1. Arrange it under `backend/dataset/train/<class>/` and
   `backend/dataset/val/<class>/` with class folders `garbage`,
   `streetlight`, `water_leakage` (see `backend/dataset/README.md`).
2. Run `docker compose exec backend python -m apps.ml.train` (or locally
   with the requirements installed). This fine-tunes a MobileNetV2
   transfer-learning model and saves it to
   `backend/ml_models/civic_issue_model.h5`.
3. Restart the backend container -- classification switches on
   automatically, no code changes needed.

## API overview

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/auth/signup/` | POST | Citizen registration (name, email, phone, password) |
| `/api/auth/login/` | POST | Login with `identifier` (email or phone) + `password` |
| `/api/auth/me/` | GET | Current user profile |
| `/api/departments/` | GET | List departments |
| `/api/complaints/` | GET/POST | List (scoped to role) / submit a complaint (image, description, lat, lng) |
| `/api/complaints/{id}/status/` | PATCH | Dept admin updates status (reported → in_progress → resolved/rejected) |
| `/api/complaints/{id}/history/` | GET | Status change audit log |
| `/api/reports/summary/` | GET | Dashboard aggregates (by status/priority/issue type/department, avg resolution time) |
| `/api/reports/export/csv/` | GET | Downloadable CSV report |

## Notes on things you'll likely want to refine

- **Priority assignment** currently uses a simple, documented rule-based
  heuristic (`apps/complaints/utils.py`) combining keyword matching and
  classification confidence -- a reasonable placeholder until your CNN
  has a dedicated severity output.
- **OTP / email verification** isn't implemented -- signup activates the
  account immediately. Add if your evaluator expects it.
- **Department-admin creation** is currently via the seed command +
  Django admin. Wire up a proper super-admin UI later if needed.
