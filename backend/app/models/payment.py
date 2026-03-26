from sqlalchemy import Column, String, Index
from sqlalchemy.dialects.postgresql import UUID, JSONB
import uuid
from app.db.base import Base

class Payment(Base):
    __tablename__ = "payments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    course_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    amount = Column(Integer, nullable=False)
    razorpay_order_id = Column(String(255), nullable=False)
    razorpay_payment_id = Column(String(255), nullable=False)
    status = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=func.now())

    __table_args__ = (
        Index("idx_payments_user", "user_id"),
    )
