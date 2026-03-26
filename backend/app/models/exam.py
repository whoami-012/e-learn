from sqlalchemy import Column, String, DateTime, Integer, ForeignKey, func, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.db.base import Base


class Exam(Base):
    __tablename__ = "exams"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    course_id = Column(UUID(as_uuid=True), ForeignKey("courses.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    duration_minutes = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=func.now())

    # Relationships
    course = relationship("Course", back_populates="exams")
    questions = relationship("Question", back_populates="exam")
    attempts = relationship("Attempt", back_populates="exam")

    __table_args__ = (
        Index("idx_exams_course", "course_id"),
    )