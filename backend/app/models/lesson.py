from sqlalchemy import Column, Enum as SQLEnum, String, DateTime, Boolean, Integer, ForeignKey, func, Index, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.db.base import Base

# Define enum once with create_type=True to avoid re-creation conflicts
lesson_type_enum = SQLEnum("video", "live", name="lesson_type", create_type=True)


class Lesson(Base):
    __tablename__ = "lessons"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    course_id = Column(UUID(as_uuid=True), ForeignKey("courses.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    type = Column(lesson_type_enum, nullable=False)
    youtube_video_id = Column(String(255), nullable=True)
    zoom_link = Column(String(255), nullable=True)
    is_preview = Column(Boolean, default=False)
    order_index = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    # Relationships
    course = relationship("Course", back_populates="lessons")

    __table_args__ = (
        # Prevents two lessons in the same course from having the same order position
        UniqueConstraint("course_id", "order_index", name="unique_lesson_order"),
        Index("idx_lessons_course", "course_id"),
    )