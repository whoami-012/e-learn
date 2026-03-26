from sqlalchemy import Column, String, DateTime, ForeignKey, func, Index, Text
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
import uuid
from app.db.base import Base


class Question(Base):
    __tablename__ = "questions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    exam_id = Column(UUID(as_uuid=True), ForeignKey("exams.id", ondelete="CASCADE"), nullable=False, index=True)
    question_text = Column(Text, nullable=False)
    options = Column(JSONB, nullable=False)       # e.g. {"A": "Paris", "B": "London", ...}
    correct_answer = Column(String(10), nullable=False)  # e.g. "A"
    created_at = Column(DateTime, default=func.now())

    # Relationships
    exam = relationship("Exam", back_populates="questions", cascade="all, delete-orphan")

    __table_args__ = (
        Index("idx_questions_exam", "exam_id"),
    )
