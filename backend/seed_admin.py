"""
seed_admin.py — One-time script to create an admin (or faculty) user.

Usage (from backend/ directory):
    python seed_admin.py

DO NOT commit real credentials. Use environment variables or prompt input.
"""

import asyncio
import os
import sys

# Add backend app to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import select
from app.db.session import AsyncSessionLocal
from app.models.user import User
from app.core.config import settings
import bcrypt


# ── Config — edit these before running ────────────────────────────────────────

ADMIN_NAME     = "Teacher"
ADMIN_EMAIL    = "teacher@elearn.com"
ADMIN_PASSWORD = "password"          # min 8 chars, 1 uppercase
ADMIN_ROLE     = "faculty"               # "admin" | "faculty" | "student"

# ──────────────────────────────────────────────────────────────────────────────


def hash_password(pw: str) -> str:
    return bcrypt.hashpw(pw.encode(), bcrypt.gensalt()).decode()


async def seed():
    async with AsyncSessionLocal() as db:
        # Check if user already exists
        result = await db.execute(
            select(User).where(User.email == ADMIN_EMAIL.lower().strip())
        )
        existing = result.scalar_one_or_none()

        if existing:
            print(f"[!] User '{ADMIN_EMAIL}' already exists with role '{existing.role}'.")
            print(f"    To change role, run: UPDATE users SET role='{ADMIN_ROLE}' WHERE email='{ADMIN_EMAIL}';")
            return

        user = User(
            name=ADMIN_NAME,
            email=ADMIN_EMAIL.lower().strip(),
            password_hash=hash_password(ADMIN_PASSWORD),
            role=ADMIN_ROLE,
            is_active=True,
            is_deleted=False,
        )

        db.add(user)
        await db.commit()
        await db.refresh(user)

        print(f"[✓] Created {ADMIN_ROLE} user:")
        print(f"    ID    : {user.id}")
        print(f"    Name  : {user.name}")
        print(f"    Email : {user.email}")
        print(f"    Role  : {user.role}")
        print(f"\n    Login with: {ADMIN_EMAIL} / {ADMIN_PASSWORD}")


if __name__ == "__main__":
    asyncio.run(seed())
