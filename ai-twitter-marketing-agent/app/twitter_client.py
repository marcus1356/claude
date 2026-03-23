import tweepy
import os
import logging

logger = logging.getLogger(__name__)


def get_twitter_client() -> tweepy.Client:
    return tweepy.Client(
        bearer_token=os.getenv("TWITTER_BEARER_TOKEN"),
        consumer_key=os.getenv("TWITTER_API_KEY"),
        consumer_secret=os.getenv("TWITTER_API_SECRET"),
        access_token=os.getenv("TWITTER_ACCESS_TOKEN"),
        access_token_secret=os.getenv("TWITTER_ACCESS_TOKEN_SECRET"),
    )


def post_tweet(text: str) -> str:
    client = get_twitter_client()
    response = client.create_tweet(text=text)
    tweet_id = str(response.data["id"])
    logger.info(f"Tweet posted successfully. ID: {tweet_id}")
    return tweet_id
