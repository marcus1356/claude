import json
import os
import logging
from dataclasses import dataclass

from app.platforms.base import PlatformClient

logger = logging.getLogger(__name__)

PLATFORM_CLASSES: dict[str, type[PlatformClient]] = {}


def _load_platform_classes():
    """Lazy-load platform classes to avoid import errors for uninstalled deps."""
    if PLATFORM_CLASSES:
        return
    from app.platforms.twitter import TwitterClient
    from app.platforms.linkedin import LinkedInClient
    from app.platforms.bluesky import BlueskyClient

    PLATFORM_CLASSES.update({
        "twitter": TwitterClient,
        "linkedin": LinkedInClient,
        "bluesky": BlueskyClient,
    })


@dataclass
class AccountConfig:
    name: str
    platform: str
    enabled: bool
    credentials: dict


class PlatformRegistry:
    """Loads accounts from accounts.json and provides platform clients."""

    def __init__(self, config_path: str = None):
        if config_path is None:
            # Go up from app/platforms/ -> app/ -> project root
            config_path = os.path.join(
                os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
                "accounts.json",
            )
        self.config_path = config_path
        self.accounts: list[AccountConfig] = []
        self._clients: dict[str, PlatformClient] = {}

    def load(self):
        _load_platform_classes()

        if not os.path.exists(self.config_path):
            logger.warning(f"accounts.json not found at {self.config_path}")
            return

        with open(self.config_path, "r") as f:
            data = json.load(f)

        self.accounts = []
        self._clients = {}

        for account_data in data.get("accounts", []):
            account = AccountConfig(
                name=account_data["name"],
                platform=account_data["platform"],
                enabled=account_data.get("enabled", True),
                credentials=account_data.get("credentials", {}),
            )
            self.accounts.append(account)

            if account.enabled:
                platform_cls = PLATFORM_CLASSES.get(account.platform)
                if platform_cls is None:
                    logger.warning(
                        f"Unknown platform '{account.platform}' for account '{account.name}'"
                    )
                    continue
                self._clients[account.name] = platform_cls(
                    account_name=account.name,
                    credentials=account.credentials,
                )
                logger.info(
                    f"Loaded account: {account.name} ({account.platform})"
                )

    def get_active_clients(self) -> list[PlatformClient]:
        return list(self._clients.values())

    def get_client(self, account_name: str) -> PlatformClient | None:
        return self._clients.get(account_name)

    def get_available_platforms(self) -> list[str]:
        _load_platform_classes()
        return list(PLATFORM_CLASSES.keys())

    def get_accounts_summary(self) -> list[dict]:
        return [
            {
                "name": a.name,
                "platform": a.platform,
                "enabled": a.enabled,
            }
            for a in self.accounts
        ]
