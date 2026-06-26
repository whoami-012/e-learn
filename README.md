# E-Learn

This is an e-learning project I’m building with a FastAPI backend and a Flutter app.

Right now, the base setup is in place and the auth flow is the most complete part. The repo also includes a dashboard redesign folder and a local `servers/` workspace that I used during development.

## What’s in here

- `backend/` - FastAPI API, database setup, auth, and core backend logic
- `elearn_app/` - Flutter mobile app
- `Teacher Home Dashboard Redesign/` - UI redesign/prototype work
- `servers/` - local MCP/server-related workspace used during development

## Current progress

At the moment, this project already has:

- user registration
- login with JWT auth
- refresh token flow
- protected `me` endpoint
- Flutter login/register screens
- token storage on the app side
- basic home screen after login

Planned next steps are the usual e-learning features like courses, lessons, notes, exams, enrollments, and payments.

## Tech stack

- Backend: FastAPI, SQLAlchemy, Alembic, PostgreSQL
- Mobile app: Flutter
- Auth: JWT + bcrypt

## Backend setup

Move into the backend folder:

```powershell
cd backend
```

Create and activate a virtual environment if you haven’t already:

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

Install dependencies:

```powershell
pip install -r requirements.txt
```

Create your `.env` file from the example:

```powershell
copy .env.example .env
```

Run the API:

```powershell
uvicorn app.main:app --reload
```

Useful URLs once it’s running:

- Swagger docs: `http://127.0.0.1:8000/docs`
- ReDoc: `http://127.0.0.1:8000/redoc`
- Health check: `http://127.0.0.1:8000/health`

## Flutter app setup

Move into the app folder:

```powershell
cd elearn_app
```

Install packages:

```powershell
flutter pub get
```

Run the app:

```powershell
flutter run
```

If you’re using the Android emulator, the app is set up around the usual local backend pattern like `10.0.2.2` for reaching your machine from the emulator.

## Notes

- This is still an MVP-stage project.
- Some folders in this repo are experiments or side work, not just production code.
- Environment files and generated files are ignored in Git.

## TODO

- course listing and detail flow
- enrollments
- lessons and video/live class support
- notes and PDF viewing
- MCQ exams
- payments
- admin/faculty features

## Author

Personal project for learning and building out a full e-learning platform step by step.
