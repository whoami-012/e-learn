from sqlalchemy import Column, String, Index
from sqlalchemy.dialects.postgresql import UUID, JSONB
import uuid
from app.db.base import Base

class Attempt(Base):
    __tablename__ = "attempts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    exam_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    score = Column(Integer, nullable=False)
    submitted_at = Column(DateTime, default=func.now())
