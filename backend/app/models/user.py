from sqlalchemy import Column, Enum as SQLEnum, String, DateTime, Boolean, func, Index
from sqlalchemy.dialects.postgresql import UUID
import uuid
from app.db.base import Base


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(SQLEnum("student", "faculty", "admin", name="user_role"), nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())

    __table_args__ = (
        Index("idx_users_email", "email"),
    )
