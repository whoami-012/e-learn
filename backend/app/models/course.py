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
    # nullable=True + SET NULL: course survives if faculty is deleted
    faculty_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    thumbnail_url = Column(String(255), nullable=True)
    is_deleted = Column(Boolean, default=False)  # soft delete
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    # Relationships
    # passive_deletes=True: SQLAlchemy won't load children on delete; DB handles cascades
    faculty = relationship("User", back_populates="courses", foreign_keys=[faculty_id], passive_deletes=True)
    enrollments = relationship("Enrollment", back_populates="course", cascade="all, delete-orphan")
    payments = relationship("Payment", back_populates="course", cascade="all, delete-orphan")
    lessons = relationship("Lesson", back_populates="course", cascade="all, delete-orphan")
    exams = relationship("Exam", back_populates="course", cascade="all, delete-orphan")
    notes = relationship("Note", back_populates="course", cascade="all, delete-orphan")

    __table_args__ = (
        Index("idx_courses_faculty", "faculty_id"),
    )