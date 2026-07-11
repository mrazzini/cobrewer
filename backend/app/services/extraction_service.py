"""OpenAI vision service for extracting bean details from bag photos."""

import base64
import json

from openai import AsyncOpenAI

from app.config import settings
from app.schemas.extract import ExtractionResult

EXTRACTION_PROMPT = """\
You are a specialty coffee expert. Extract the coffee bean details from this \
photo of a coffee bag label. Return ONLY a JSON object with these keys (use \
null for anything not visible on the bag):
- name: the coffee's name as printed on the bag
- roaster: the roastery name
- origin: country (and region if shown), e.g. "Ethiopia, Yirgacheffe"
- variety: coffee variety, e.g. "Heirloom", "Geisha", "Bourbon"
- process: one of "washed", "natural", "honey", "anaerobic", "wet_hulled" (map \
similar terms; e.g. "fully washed" -> "washed")
- roast_level: one of "light", "medium_light", "medium", "medium_dark", "dark"
- tasting_notes: array of short flavour descriptors, e.g. ["jasmine", "bergamot"]
"""


def is_configured() -> bool:
    return bool(settings.OPENAI_API_KEY)


async def extract_from_image(image_bytes: bytes, content_type: str) -> ExtractionResult:
    client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
    b64 = base64.b64encode(image_bytes).decode()
    response = await client.chat.completions.create(
        model="gpt-4o-mini",
        response_format={"type": "json_object"},
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": EXTRACTION_PROMPT},
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:{content_type};base64,{b64}"},
                    },
                ],
            }
        ],
        max_tokens=500,
    )
    raw = response.choices[0].message.content or "{}"
    return ExtractionResult.model_validate(json.loads(raw))
