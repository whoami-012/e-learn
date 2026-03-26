from sqlalchemy import Column, String, Index
from sqlalchemy.dialects.postgresql import UUID, JSONB
import uuid
from app.db.base import Base


class Question(Base):
    __tablename__ = "questions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    exam_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    question_text = Column(String(255), nullable=False)
    options = Column(JSONB, nullable=False)       # e.g. {"A": "Paris", "B": "London", ...}
    correct_answer = Column(String(10), nullable=False)  # e.g. "A"

    __table_args__ = (
        Index("idx_questions_exam", "exam_id"),
    )
