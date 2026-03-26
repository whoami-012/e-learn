from sqlalchemy import Column, String, DateTime, Integer, ForeignKey, func, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.db.base import Base


class Payment(Base):
    __tablename__ = "payments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    course_id = Column(UUID(as_uuid=True), ForeignKey("courses.id", ondelete="CASCADE"), nullable=False, index=True)
    amount = Column(Integer, nullable=False)
    razorpay_order_id = Column(String(255), nullable=False)
    razorpay_payment_id = Column(String(255), nullable=True)
    status = Column(String(50), nullable=False)  # e.g. "pending", "success", "failed"
    created_at = Column(DateTime, default=func.now())

    # Relationships
    user = relationship("User", back_populates="payments")
    course = relationship("Course", back_populates="payments")
    enrollment = relationship("Enrollment", back_populates="payment", uselist=False)

    __table_args__ = (
        Index("idx_payments_user", "user_id"),
        Index("idx_payments_course", "course_id"),
    )
