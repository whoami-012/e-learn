from fastapi import APIRouter
from app.api.v1.endpoints import auth, courses, upload, notes, enrollments

# Central v1 router — all endpoint routers are registered here
api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(courses.router)
api_router.include_router(upload.router)
api_router.include_router(notes.router)
api_router.include_router(enrollments.router)
# Future routers go here, e.g.:
# api_router.include_router(lessons.router)

