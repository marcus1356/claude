import logging

from app.platforms.base import PlatformClient, PostResult

logger = logging.getLogger(__name__)


class LinkedInClient(PlatformClient):
    """LinkedIn integration placeholder.

    To fully implement, you need to:
    1. Register an app at https://developer.linkedin.com
    2. Get an OAuth 2.0 access token with w_member_social scope
    3. Install the requests library (already common)

    The LinkedIn API uses POST https://api.linkedin.com/v2/ugcPosts
    """

    platform_name = "linkedin"
    max_length = 3000
    supports_images = False

    def post(self, text: str) -> PostResult:
        import requests

        access_token = self.credentials.get("access_token")
        person_id = self.credentials.get("person_id")

        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
            "X-Restli-Protocol-Version": "2.0.0",
        }

        payload = {
            "author": f"urn:li:person:{person_id}",
            "lifecycleState": "PUBLISHED",
            "specificContent": {
                "com.linkedin.ugc.ShareContent": {
                    "shareCommentary": {"text": text},
                    "shareMediaCategory": "NONE",
                }
            },
            "visibility": {
                "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"
            },
        }

        response = requests.post(
            "https://api.linkedin.com/v2/ugcPosts",
            headers=headers,
            json=payload,
        )
        response.raise_for_status()
        post_id = response.json().get("id", "")
        logger.info(f"[{self.account_name}] LinkedIn post created. ID: {post_id}")
        return PostResult(external_id=post_id)

    def validate_credentials(self) -> bool:
        try:
            import requests

            access_token = self.credentials.get("access_token")
            headers = {"Authorization": f"Bearer {access_token}"}
            response = requests.get(
                "https://api.linkedin.com/v2/me", headers=headers
            )
            return response.status_code == 200
        except Exception as e:
            logger.error(f"[{self.account_name}] LinkedIn validation failed: {e}")
            return False

    def get_content_rules(self) -> str:
        return (
            "- Maximum 3000 characters but keep it under 1300 for best engagement\n"
            "- Professional tone\n"
            "- Use line breaks for readability\n"
            "- Include 3-5 relevant hashtags at the end\n"
            "- Start with a hook (first 2 lines are visible before 'see more')\n"
            "- Share insights, lessons learned, or industry perspectives"
        )
