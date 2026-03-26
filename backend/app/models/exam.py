from sqlalchemy import Column, Enum as SQLEnum, String, DateTime, Boolean, func, Index
from sqlalchemy.dialects.postgresql import UUID
import uuid
from app.db.base import Base

class Exam(Base):
    __tablename__ = "exams"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    course_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    duration_minutes = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=func.now())