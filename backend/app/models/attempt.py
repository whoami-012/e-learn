from sqlalchemy import Column, DateTime, Integer, ForeignKey, func, Index
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
import uuid
from app.db.base import Base


class Attempt(Base):
    __tablename__ = "attempts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    exam_id = Column(UUID(as_uuid=True), ForeignKey("exams.id", ondelete="CASCADE"), nullable=False, index=True)
    answers = Column(JSONB, nullable=False)   # e.g. {"q1_id": "A", "q2_id": "C", ...}
    score = Column(Integer, nullable=False)
    submitted_at = Column(DateTime, default=func.now())

    # Relationships
    user = relationship("User", back_populates="attempts")
    exam = relationship("Exam", back_populates="attempts")

    __table_args__ = (
        Index("idx_attempts_user", "user_id"),
        Index("idx_attempts_exam", "exam_id"),
    )
