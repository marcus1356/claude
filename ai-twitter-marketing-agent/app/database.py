import aiosqlite
import os
from datetime import datetime

DB_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "posts.db")


async def init_db():
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("""
            CREATE TABLE IF NOT EXISTS posts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                content TEXT NOT NULL,
                tweet_id TEXT,
                status TEXT NOT NULL DEFAULT 'pending',
                error_message TEXT,
                created_at TEXT NOT NULL,
                posted_at TEXT
            )
        """)
        await db.commit()


async def save_post(content: str, status: str = "pending") -> int:
    async with aiosqlite.connect(DB_PATH) as db:
        cursor = await db.execute(
            "INSERT INTO posts (content, status, created_at) VALUES (?, ?, ?)",
            (content, status, datetime.utcnow().isoformat()),
        )
        await db.commit()
        return cursor.lastrowid


async def update_post_status(
    post_id: int, status: str, tweet_id: str = None, error_message: str = None
):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            """UPDATE posts
               SET status = ?, tweet_id = ?, error_message = ?, posted_at = ?
               WHERE id = ?""",
            (status, tweet_id, error_message, datetime.utcnow().isoformat(), post_id),
        )
        await db.commit()


async def get_all_posts(limit: int = 50, offset: int = 0) -> list[dict]:
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        cursor = await db.execute(
            "SELECT * FROM posts ORDER BY created_at DESC LIMIT ? OFFSET ?",
            (limit, offset),
        )
        rows = await cursor.fetchall()
        return [dict(row) for row in rows]


async def get_post_stats() -> dict:
    async with aiosqlite.connect(DB_PATH) as db:
        cursor = await db.execute("SELECT COUNT(*) FROM posts")
        total = (await cursor.fetchone())[0]

        cursor = await db.execute(
            "SELECT COUNT(*) FROM posts WHERE status = 'posted'"
        )
        posted = (await cursor.fetchone())[0]

        cursor = await db.execute(
            "SELECT COUNT(*) FROM posts WHERE status = 'failed'"
        )
        failed = (await cursor.fetchone())[0]

        cursor = await db.execute(
            "SELECT COUNT(*) FROM posts WHERE status = 'pending'"
        )
        pending = (await cursor.fetchone())[0]

        return {
            "total": total,
            "posted": posted,
            "failed": failed,
            "pending": pending,
        }
