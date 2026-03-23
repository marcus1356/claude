import tweepy
import random
import logging

from app.platforms.base import PlatformClient, PostResult

logger = logging.getLogger(__name__)


class TwitterClient(PlatformClient):
    platform_name = "twitter"
    max_length = 280
    supports_images = False

    def _is_demo(self) -> bool:
        return self.credentials.get("api_key") == "demo"

    def _get_client(self) -> tweepy.Client:
        return tweepy.Client(
            bearer_token=self.credentials.get("bearer_token"),
            consumer_key=self.credentials.get("api_key"),
            consumer_secret=self.credentials.get("api_secret"),
            access_token=self.credentials.get("access_token"),
            access_token_secret=self.credentials.get("access_token_secret"),
        )

    def post(self, text: str) -> PostResult:
        if self._is_demo():
            fake_id = str(random.randint(1_000_000_000, 9_999_999_999))
            logger.info(f"[{self.account_name}] [DEMO] Tweet simulated. ID: {fake_id}")
            return PostResult(
                external_id=fake_id,
                url=f"https://twitter.com/i/status/{fake_id}",
            )

        client = self._get_client()
        response = client.create_tweet(text=text)
        tweet_id = str(response.data["id"])
        logger.info(f"[{self.account_name}] Tweet posted. ID: {tweet_id}")
        return PostResult(
            external_id=tweet_id,
            url=f"https://twitter.com/i/status/{tweet_id}",
        )

    def validate_credentials(self) -> bool:
        try:
            client = self._get_client()
            client.get_me()
            return True
        except Exception as e:
            logger.error(f"[{self.account_name}] Twitter credential validation failed: {e}")
            return False

    def get_content_rules(self) -> str:
        return (
            "- Maximum 280 characters\n"
            "- Include 1-2 relevant hashtags\n"
            "- Be concise and engaging\n"
            "- Tweets with questions or tips tend to perform well"
        )

    def get_post_url(self, external_id: str) -> str | None:
        return f"https://twitter.com/i/status/{external_id}"
