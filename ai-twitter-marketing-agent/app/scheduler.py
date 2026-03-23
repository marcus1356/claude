import os
import asyncio
import logging
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from app.agent import run_daily_post

logger = logging.getLogger(__name__)

scheduler = AsyncIOScheduler()


def start_scheduler():
    hour = int(os.getenv("POST_HOUR", "9"))
    minute = int(os.getenv("POST_MINUTE", "0"))

    scheduler.add_job(
        lambda: asyncio.ensure_future(run_daily_post()),
        trigger="cron",
        hour=hour,
        minute=minute,
        id="daily_post_all_platforms",
        replace_existing=True,
    )
    scheduler.start()
    logger.info(f"Scheduler started. Daily post scheduled at {hour:02d}:{minute:02d}")


def stop_scheduler():
    if scheduler.running:
        scheduler.shutdown()
        logger.info("Scheduler stopped.")
