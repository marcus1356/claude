import logging
from datetime import datetime, timezone

from app.platforms.base import PlatformClient, PostResult

logger = logging.getLogger(__name__)


class BlueskyClient(PlatformClient):
    """Bluesky/AT Protocol integration.

    To use:
    1. Create an app password at https://bsky.app/settings/app-passwords
    2. Set handle and app_password in credentials
    """

    platform_name = "bluesky"
    max_length = 300
    supports_images = False

    def _create_session(self) -> dict:
        import requests

        service = self.credentials.get("service", "https://bsky.social")
        response = requests.post(
            f"{service}/xrpc/com.atproto.server.createSession",
            json={
                "identifier": self.credentials["handle"],
                "password": self.credentials["app_password"],
            },
        )
        response.raise_for_status()
        return response.json()

    def post(self, text: str) -> PostResult:
        import requests

        session = self._create_session()
        service = self.credentials.get("service", "https://bsky.social")

        record = {
            "text": text,
            "$type": "app.bsky.feed.post",
            "createdAt": datetime.now(timezone.utc).isoformat(),
        }

        response = requests.post(
            f"{service}/xrpc/com.atproto.repo.createRecord",
            headers={"Authorization": f"Bearer {session['accessJwt']}"},
            json={
                "repo": session["did"],
                "collection": "app.bsky.feed.post",
                "record": record,
            },
        )
        response.raise_for_status()
        data = response.json()
        post_uri = data.get("uri", "")
        logger.info(f"[{self.account_name}] Bluesky post created. URI: {post_uri}")

        # Build web URL from URI: at://did/collection/rkey
        rkey = post_uri.split("/")[-1] if "/" in post_uri else ""
        handle = self.credentials["handle"]
        url = f"https://bsky.app/profile/{handle}/post/{rkey}" if rkey else None

        return PostResult(external_id=post_uri, url=url)

    def validate_credentials(self) -> bool:
        try:
            self._create_session()
            return True
        except Exception as e:
            logger.error(f"[{self.account_name}] Bluesky validation failed: {e}")
            return False

    def get_content_rules(self) -> str:
        return (
            "- Maximum 300 characters\n"
            "- Bluesky is more conversational and community-driven\n"
            "- Hashtags are not commonly used on Bluesky\n"
            "- Focus on authentic, thoughtful content"
        )
