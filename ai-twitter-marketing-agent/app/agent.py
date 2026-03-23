import logging
from app.content_generator import generate_tweet
from app.twitter_client import post_tweet
from app.database import save_post, update_post_status

logger = logging.getLogger(__name__)


async def run_daily_post():
    """Generate content and post to Twitter. Called by the scheduler."""
    logger.info("Starting daily post job...")

    try:
        tweet_text = generate_tweet()
    except Exception as e:
        logger.error(f"Failed to generate content: {e}")
        return

    post_id = await save_post(content=tweet_text, status="pending")

    try:
        tweet_id = post_tweet(tweet_text)
        await update_post_status(post_id, status="posted", tweet_id=tweet_id)
        logger.info(f"Daily post completed. Post ID: {post_id}, Tweet ID: {tweet_id}")
    except Exception as e:
        logger.error(f"Failed to post tweet: {e}")
        await update_post_status(post_id, status="failed", error_message=str(e))
