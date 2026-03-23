import anthropic
import os
import logging

from app.platforms.base import PlatformClient

logger = logging.getLogger(__name__)


def get_client() -> anthropic.Anthropic:
    return anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))


def generate_content(platform_client: PlatformClient) -> str:
    """Generate content tailored for a specific platform."""
    brand_name = os.getenv("BRAND_NAME", "MyBrand")
    brand_description = os.getenv("BRAND_DESCRIPTION", "")
    brand_tone = os.getenv("BRAND_TONE", "professional, friendly")
    brand_topics = os.getenv("BRAND_TOPICS", "technology, innovation")
    platform_rules = platform_client.get_content_rules()

    prompt = f"""You are a social media marketing expert. Generate a single post for {platform_client.platform_name.upper()} for the brand below.

Brand: {brand_name}
Description: {brand_description}
Tone: {brand_tone}
Topics to cover (pick one): {brand_topics}

Platform-specific rules:
{platform_rules}

General rules:
- Be engaging and authentic
- Do NOT wrap the text in quotes
- Vary the style: sometimes ask a question, sometimes share a tip, sometimes share an insight
- Write in the brand's voice
- Return ONLY the post text, nothing else
"""

    client = get_client()
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}],
    )

    text = message.content[0].text.strip()

    max_len = platform_client.max_length
    if len(text) > max_len:
        text = text[: max_len - 3] + "..."

    logger.info(
        f"Generated {platform_client.platform_name} content "
        f"for [{platform_client.account_name}] ({len(text)} chars): {text[:80]}..."
    )
    return text
