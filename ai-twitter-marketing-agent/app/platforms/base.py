from abc import ABC, abstractmethod
from dataclasses import dataclass


@dataclass
class PostResult:
    external_id: str
    url: str | None = None


class PlatformClient(ABC):
    """Base class for all social media platform integrations."""

    platform_name: str = "unknown"
    max_length: int = 280
    supports_images: bool = False

    def __init__(self, account_name: str, credentials: dict):
        self.account_name = account_name
        self.credentials = credentials

    @abstractmethod
    def post(self, text: str) -> PostResult:
        """Publish text content to the platform. Returns the external post ID."""

    @abstractmethod
    def validate_credentials(self) -> bool:
        """Check if the credentials are valid."""

    def get_content_rules(self) -> str:
        """Return platform-specific content generation rules for the AI prompt."""
        return f"- Maximum {self.max_length} characters"

    def get_post_url(self, external_id: str) -> str | None:
        """Return a URL to view the post on the platform, if available."""
        return None
