import anthropic
import os
import logging

logger = logging.getLogger(__name__)


def get_client() -> anthropic.Anthropic:
    return anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))


def generate_tweet(brand_name: str = None, brand_description: str = None,
                   brand_tone: str = None, brand_topics: str = None) -> str:
    brand_name = brand_name or os.getenv("BRAND_NAME", "MyBrand")
    brand_description = brand_description or os.getenv("BRAND_DESCRIPTION", "")
    brand_tone = brand_tone or os.getenv("BRAND_TONE", "professional, friendly")
    brand_topics = brand_topics or os.getenv("BRAND_TOPICS", "technology, innovation")

    prompt = f"""You are a social media marketing expert. Generate a single tweet for the brand below.

Brand: {brand_name}
Description: {brand_description}
Tone: {brand_tone}
Topics to cover (pick one): {brand_topics}

Rules:
- Maximum 280 characters
- Be engaging and authentic
- Include 1-2 relevant hashtags
- Do NOT use quotes around the tweet
- Vary the style: sometimes ask a question, sometimes share a tip, sometimes share an insight
- Write in the brand's voice
- Return ONLY the tweet text, nothing else
"""

    client = get_client()
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=300,
        messages=[{"role": "user", "content": prompt}],
    )

    tweet_text = message.content[0].text.strip()

    if len(tweet_text) > 280:
        tweet_text = tweet_text[:277] + "..."

    logger.info(f"Generated tweet ({len(tweet_text)} chars): {tweet_text}")
    return tweet_text
