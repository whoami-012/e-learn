from sqlalchemy import Column, Enum as SQLEnum, String, DateTime, Boolean, func, Index
from sqlalchemy.dialects.postgresql import UUID
import uuid
from app.db.base import Base

class Course(Base):
    __tablename__ = "courses"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    price = Column(Numeric(precision=10, scale=2), nullable=False)
    is_free = Column(Boolean, default=False)
    faculty_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    thumbnail_url = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=func.now())

    __table_args__ = (
        Index("idx_courses_faculty", "faculty_id"),
    )