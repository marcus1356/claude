import os
import logging
from contextlib import asynccontextmanager
from pathlib import Path

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles

from app import agent
from app.content_generator import generate_preview_content
from app.database import get_all_posts, get_post_stats, init_db
from app.platforms.registry import PlatformRegistry
from app.scheduler import start_scheduler, stop_scheduler

BASE_DIR = Path(__file__).resolve().parent

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)

registry = PlatformRegistry()


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    registry.load()
    agent.registry = registry
    start_scheduler()
    active = len(registry.get_active_clients())
    logger.info(
        f"AI Marketing Agent running with {active} active account(s)."
    )
    yield
    stop_scheduler()


app = FastAPI(title="AI Social Media Marketing Agent", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

static_dir = BASE_DIR / "static"
if static_dir.is_dir() and any(static_dir.iterdir()):
    app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")


@app.get("/", response_class=HTMLResponse)
async def dashboard():
    html_path = BASE_DIR / "templates" / "dashboard.html"
    return html_path.read_text(encoding="utf-8")


@app.get("/api/posts")
async def api_posts(limit: int = 50, offset: int = 0, platform: str = None):
    return await get_all_posts(limit=limit, offset=offset, platform=platform)


@app.get("/api/stats")
async def api_stats(platform: str = None):
    return await get_post_stats(platform=platform)


@app.get("/api/accounts")
async def api_accounts():
    return {
        "accounts": registry.get_accounts_summary(),
        "available_platforms": registry.get_available_platforms(),
    }


@app.get("/api/generate-preview")
async def api_generate_preview():
    """Generate content preview based on trending topics without posting."""
    try:
        result = generate_preview_content()
        return result
    except Exception as e:
        logger.error(f"Preview generation failed: {e}")
        return {"error": str(e)}


@app.post("/api/post-now")
async def api_post_now(account: str = None):
    """Post now to all accounts or a specific one."""
    try:
        if account:
            await agent.post_to_account(account)
        else:
            await agent.run_daily_post()
        return {"status": "ok"}
    except Exception as e:
        logger.error(f"Manual post failed: {e}")
        return {"error": str(e)}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
