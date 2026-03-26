from sqlalchemy import Column, String, Text, DateTime, Boolean, Numeric, ForeignKey, func, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.db.base import Base


class Course(Base):
    __tablename__ = "courses"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    price = Column(Numeric(precision=10, scale=2), nullable=False)
    is_free = Column(Boolean, default=False)
    faculty_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=False, index=True)
    thumbnail_url = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=func.now())

    # Relationships
    faculty = relationship("User", back_populates="courses", foreign_keys=[faculty_id])
    enrollments = relationship("Enrollment", back_populates="course")
    payments = relationship("Payment", back_populates="course")
    lessons = relationship("Lesson", back_populates="course")
    exams = relationship("Exam", back_populates="course")
    notes = relationship("Note", back_populates="course")

    __table_args__ = (
        Index("idx_courses_faculty", "faculty_id"),
    )