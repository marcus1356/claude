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
                platform TEXT NOT NULL DEFAULT 'twitter',
                account_name TEXT NOT NULL DEFAULT 'default',
                external_id TEXT,
                external_url TEXT,
                status TEXT NOT NULL DEFAULT 'pending',
                error_message TEXT,
                created_at TEXT NOT NULL,
                posted_at TEXT
            )
        """)
        await db.commit()


async def save_post(
    content: str, platform: str, account_name: str, status: str = "pending"
) -> int:
    async with aiosqlite.connect(DB_PATH) as db:
        cursor = await db.execute(
            """INSERT INTO posts (content, platform, account_name, status, created_at)
               VALUES (?, ?, ?, ?, ?)""",
            (content, platform, account_name, status, datetime.utcnow().isoformat()),
        )
        await db.commit()
        return cursor.lastrowid


async def update_post_status(
    post_id: int,
    status: str,
    external_id: str = None,
    external_url: str = None,
    error_message: str = None,
):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            """UPDATE posts
               SET status = ?, external_id = ?, external_url = ?,
                   error_message = ?, posted_at = ?
               WHERE id = ?""",
            (
                status,
                external_id,
                external_url,
                error_message,
                datetime.utcnow().isoformat(),
                post_id,
            ),
        )
        await db.commit()


async def get_all_posts(
    limit: int = 50, offset: int = 0, platform: str = None
) -> list[dict]:
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        if platform:
            cursor = await db.execute(
                """SELECT * FROM posts WHERE platform = ?
                   ORDER BY created_at DESC LIMIT ? OFFSET ?""",
                (platform, limit, offset),
            )
        else:
            cursor = await db.execute(
                "SELECT * FROM posts ORDER BY created_at DESC LIMIT ? OFFSET ?",
                (limit, offset),
            )
        rows = await cursor.fetchall()
        return [dict(row) for row in rows]


async def get_post_stats(platform: str = None) -> dict:
    async with aiosqlite.connect(DB_PATH) as db:
        where = "WHERE platform = ?" if platform else ""
        params = (platform,) if platform else ()

        cursor = await db.execute(f"SELECT COUNT(*) FROM posts {where}", params)
        total = (await cursor.fetchone())[0]

        cursor = await db.execute(
            f"SELECT COUNT(*) FROM posts {where} {'AND' if platform else 'WHERE'} status = 'posted'",
            params,
        )
        posted = (await cursor.fetchone())[0]

        cursor = await db.execute(
            f"SELECT COUNT(*) FROM posts {where} {'AND' if platform else 'WHERE'} status = 'failed'",
            params,
        )
        failed = (await cursor.fetchone())[0]

        cursor = await db.execute(
            f"SELECT COUNT(*) FROM posts {where} {'AND' if platform else 'WHERE'} status = 'pending'",
            params,
        )
        pending = (await cursor.fetchone())[0]

        return {
            "total": total,
            "posted": posted,
            "failed": failed,
            "pending": pending,
        }
