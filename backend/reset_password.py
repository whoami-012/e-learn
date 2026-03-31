"""
reset_password.py — Reset a user's password directly in the database.

Usage (from backend/ directory):
    python reset_password.py
"""

import asyncio
import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import select
from app.db.session import AsyncSessionLocal
from app.models.user import User
import bcrypt


# ── Config — edit before running ──────────────────────────────────────────────

TARGET_EMAIL = "admin@elearn.com"
NEW_PASSWORD = "password"

# ──────────────────────────────────────────────────────────────────────────────


async def reset():
    async with AsyncSessionLocal() as db:
        result = await db.execute(
            select(User).where(User.email == TARGET_EMAIL.lower().strip())
        )
        user = result.scalar_one_or_none()

        if not user:
            print(f"[!] No user found with email: {TARGET_EMAIL}")
            return

        user.password_hash = bcrypt.hashpw(
            NEW_PASSWORD.encode(), bcrypt.gensalt()
        ).decode()

        await db.commit()

        print(f"[✓] Password updated for: {user.email}")
        print(f"    New password: {NEW_PASSWORD}")


if __name__ == "__main__":
    asyncio.run(reset())
