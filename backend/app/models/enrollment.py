from sqlalchemy import Column, Enum as SQLEnum, String, DateTime, Boolean, func, Index
from sqlalchemy.dialects.postgresql import UUID
import uuid
from app.db.base import Base

class Enrollment(Base):
    __tablename__ = "enrollments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    course_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    payment_id = Column(UUID(as_uuid=True), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())