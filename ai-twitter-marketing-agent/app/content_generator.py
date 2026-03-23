import anthropic
import os
import random
import logging

from app.platforms.base import PlatformClient

logger = logging.getLogger(__name__)

DEMO_TWEETS = [
    "The future of productivity isn't working harder — it's working smarter with AI. What's one task you'd love to automate? #AI #Productivity",
    "Innovation doesn't happen in isolation. The best ideas come from collaboration between humans and technology. #Innovation #Tech",
    "Quick tip: Start your day by tackling the most creative task first. Your brain is freshest in the morning. #ProductivityTip #MyBrand",
    "We believe technology should simplify life, not complicate it. That's why we build tools that just work. #SimpleByDesign #Tech",
    "What if AI could handle the repetitive work so you could focus on what truly matters? That future is closer than you think. #AI #Future",
    "3 signs your team needs better tools:\n1. Too many manual processes\n2. Data lives in silos\n3. Decisions take weeks, not hours\n\nSound familiar? #Innovation",
    "The companies that will lead tomorrow are the ones investing in AI today. Not to replace people — to empower them. #AITransformation",
    "Every great product starts with a simple question: how can we make this easier? #ProductDesign #Innovation",
]

DEMO_LINKEDIN = [
    "I've been thinking a lot about the intersection of AI and human creativity.\n\nThe companies that get this right aren't the ones replacing people with algorithms. They're the ones using AI to amplify what humans do best: think creatively, build relationships, and solve complex problems.\n\nAt MyBrand, we've seen a 40% increase in team productivity — not because people are working more, but because they're spending time on work that actually matters.\n\nThe future belongs to human + AI collaboration.\n\n#AI #Innovation #FutureOfWork #Leadership #Productivity",
    "Hot take: Most companies don't have a technology problem. They have a process problem.\n\nYou can buy the best tools in the world, but if your workflows are broken, you're just automating chaos.\n\nHere's what actually works:\n→ Map your current processes first\n→ Identify the real bottlenecks\n→ Then find the right tool for each gap\n→ Measure impact, not just adoption\n\nTechnology is an accelerator, not a fix.\n\n#ProcessImprovement #Tech #BusinessStrategy #Innovation",
]


def _is_demo_mode() -> bool:
    key = os.getenv("ANTHROPIC_API_KEY", "")
    return not key or key == "demo"


def get_client() -> anthropic.Anthropic:
    return anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))


def generate_content(platform_client: PlatformClient) -> str:
    """Generate content tailored for a specific platform."""

    if _is_demo_mode():
        return _generate_demo_content(platform_client)

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


def _generate_demo_content(platform_client: PlatformClient) -> str:
    """Generate demo content without calling the API."""
    if platform_client.platform_name == "linkedin":
        text = random.choice(DEMO_LINKEDIN)
    else:
        text = random.choice(DEMO_TWEETS)

    logger.info(
        f"[DEMO] Generated {platform_client.platform_name} content "
        f"for [{platform_client.account_name}] ({len(text)} chars)"
    )
    return text
