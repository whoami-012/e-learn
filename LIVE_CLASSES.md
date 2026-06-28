# Agora live classes

This feature reuses the FastAPI/JWT/SQLAlchemy backend and Flutter Provider architecture. Channel names and RTC tokens are created only by the backend. Flutter receives the public App ID, generated channel, numeric UID, role, and short-lived token; the App Certificate is never returned.

## Setup

1. Create an Agora project, enable its App Certificate, and copy the App ID and primary certificate.
2. Copy `backend/.env.example` to `backend/.env` and set `AGORA_APP_ID` and `AGORA_APP_CERTIFICATE`. Never put the certificate in Dart code or commit `.env`.
3. Install and migrate:

   ```powershell
   cd backend
   python -m pip install -r requirements.txt
   alembic -c app/alembic.ini upgrade head
   uvicorn app.main:app --reload --port 8001
   ```

4. Resolve and run Flutter:

   ```powershell
   cd elearn_app
   flutter pub get
   flutter run
   ```

Agora 6.5.4 is selected because 6.6.3 conflicts with the app's current `flutter_secure_storage` package through incompatible `ffi` constraints. `permission_handler` 12.0.3 supports the project's Dart 3.5 minimum.

Optional settings are `LIVE_CLASS_EARLY_JOIN_MINUTES=10`, `LIVE_CLASS_ATTENDANCE_THRESHOLD=0.75`, and `LIVE_CLASS_TOKEN_BUFFER_MINUTES=15`. API timestamps must include an offset and are stored as UTC. Flutter uses the device timezone.

## Mobile permissions

Android declares internet, network state, audio settings, microphone, camera, and Bluetooth-connect permissions in `android/app/src/main/AndroidManifest.xml`. iOS declares camera and microphone usage descriptions in `ios/Runner/Info.plist`. Audience students are not asked for either permission; faculty must grant both before broadcasting.

## API

All routes require `Authorization: Bearer <JWT>` and use `/api/v1`.

```http
POST /api/v1/live-classes
Content-Type: application/json

{
  "course_id": "de3d85e5-f9f0-4f49-bc09-1d23f3591981",
  "title": "Physics Live Class",
  "description": "Motion and forces",
  "scheduled_start_time": "2026-06-28T04:30:00Z",
  "scheduled_end_time": "2026-06-28T05:30:00Z"
}
```

Join, start, and refresh return:

```json
{
  "liveClassId": "ab18e5b4-b223-4df3-bbba-12b57e074031",
  "appId": "public-agora-app-id",
  "channelName": "course_de3d85e5_random-suffix",
  "token": "short-lived-rtc-token",
  "uid": 5839201,
  "role": "audience",
  "tokenExpiresAt": "2026-06-28T06:45:00Z",
  "class": {
    "title": "Physics Live Class",
    "facultyName": "Faculty Name",
    "scheduled_start_time": "2026-06-28T04:30:00Z",
    "status": "live"
  }
}
```

Implemented routes: create/list/get/update plus `start`, `join`, `heartbeat`, `leave`, `refresh-token`, `end`, `cancel`, and attendance actions under `/live-classes/{id}`.

## Security and attendance

- Faculty ownership, enrollment, role, channel, UID, and RTC role are resolved server-side.
- Faculty use reserved UID 1. Student UIDs are derived from class/user UUIDs, collision-checked, persisted, and protected by database uniqueness constraints.
- Heartbeats update `last_seen_at` but do not add duration. Leave/end add only the current interval, so duplicate heartbeats cannot inflate attendance.
- Create/start/end/cancel/token issuance use a dedicated audit logger that never logs tokens or credentials.
- Lifecycle transitions are validated server-side and end/leave are idempotent where practical.

## Remaining operational work

- Rate limits are process-local; multi-worker production should use Redis or gateway enforcement.
- `NotificationService` is an FCM-ready boundary, but no transport or scheduled “about to start” worker exists yet.
- Server-authorized student promotion is reserved but intentionally not exposed client-side.
- Unit tests cover validation, attendance threshold behavior, UID bounds, and certificate non-exposure. Full PostgreSQL API/authorization tests need a test-database fixture, which the repository does not currently provide.
