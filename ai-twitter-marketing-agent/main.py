import asyncio
import logging
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles

from app.agent import run_daily_post
from app.database import get_all_posts, get_post_stats, init_db
from app.scheduler import start_scheduler, stop_scheduler

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    start_scheduler()
    logger.info("AI Twitter Marketing Agent is running.")
    yield
    stop_scheduler()


app = FastAPI(title="AI Twitter Marketing Agent", lifespan=lifespan)
app.mount("/static", StaticFiles(directory="static"), name="static")


@app.get("/", response_class=HTMLResponse)
async def dashboard():
    with open("templates/dashboard.html", "r") as f:
        return f.read()


@app.get("/api/posts")
async def api_posts(limit: int = 50, offset: int = 0):
    return await get_all_posts(limit=limit, offset=offset)


@app.get("/api/stats")
async def api_stats():
    return await get_post_stats()


@app.post("/api/post-now")
async def api_post_now():
    try:
        await run_daily_post()
        return {"status": "ok"}
    except Exception as e:
        logger.error(f"Manual post failed: {e}")
        return {"error": str(e)}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
