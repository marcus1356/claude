import logging

from app.content_generator import generate_content
from app.database import save_post, update_post_status
from app.platforms.base import PlatformClient

logger = logging.getLogger(__name__)

# Will be set by main.py at startup
registry = None


async def run_daily_post():
    """Generate content and post to all active platforms."""
    if registry is None:
        logger.error("Platform registry not initialized.")
        return

    clients = registry.get_active_clients()
    if not clients:
        logger.warning("No active platform accounts configured.")
        return

    logger.info(f"Starting daily post for {len(clients)} account(s)...")

    for client in clients:
        await _post_to_platform(client)


async def post_to_account(account_name: str):
    """Post to a specific account by name."""
    if registry is None:
        raise RuntimeError("Platform registry not initialized.")

    client = registry.get_client(account_name)
    if client is None:
        raise ValueError(f"Account '{account_name}' not found or not active.")

    await _post_to_platform(client)


async def _post_to_platform(client: PlatformClient):
    """Generate and post content for a single platform client."""
    try:
        content = generate_content(client)
    except Exception as e:
        logger.error(
            f"[{client.account_name}] Failed to generate content: {e}"
        )
        return

    post_id = await save_post(
        content=content,
        platform=client.platform_name,
        account_name=client.account_name,
        status="pending",
    )

    try:
        result = client.post(content)
        await update_post_status(
            post_id,
            status="posted",
            external_id=result.external_id,
            external_url=result.url,
        )
        logger.info(
            f"[{client.account_name}] Post completed. "
            f"ID: {post_id}, External: {result.external_id}"
        )
    except Exception as e:
        logger.error(f"[{client.account_name}] Failed to post: {e}")
        await update_post_status(
            post_id, status="failed", error_message=str(e)
        )
