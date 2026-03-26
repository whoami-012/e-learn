from sqlalchemy import Column, Enum as SQLEnum, String, DateTime, Boolean, func, Index
from sqlalchemy.dialects.postgresql import UUID
import uuid
from app.db.base import Base

class Lesson(Base):
    __tablename__ = "lessons"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    course_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    type = Column(SQLEnum("video", "live", name="lesson_type"), nullable=False)
    youtube_video_id = Column(String(255), nullable=True)
    zoom_link = Column(String(255), nullable=True)
    is_preview = Column(Boolean, default=False)
    order_index = Column(Integer, nullable=False)

    __table_args__ = (
        Index("idx_lessons_course", "course_id"),
    )