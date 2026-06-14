import logging

from google import genai
from google.genai import types

from app.core.settings import settings
from app.services.llm.base import DiscoverFilters, LlmProvider

logger = logging.getLogger(__name__)


class GeminiProvider(LlmProvider):
    def __init__(self) -> None:
        self._client: genai.Client | None = None
        if settings.gemini_api_key:
            self._client = genai.Client(api_key=settings.gemini_api_key)

    def parse_discover_query(self, query: str, context: dict) -> DiscoverFilters:
        if not self._client:
            raise RuntimeError("Gemini API key is not configured.")

        prompt = _build_prompt(query, context)
        response = self._client.models.generate_content(
            model=settings.llm_model,
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_json_schema=DiscoverFilters.model_json_schema(),
            ),
        )
        if not response.text:
            raise RuntimeError("Gemini returned an empty response.")
        return DiscoverFilters.model_validate_json(response.text)


def _build_prompt(query: str, context: dict) -> str:
    locations = ", ".join(context.get("locations", []))
    product_tags = ", ".join(context.get("product_tags", []))
    vibe_tags = ", ".join(context.get("vibe_tags", []))
    price_bands = ", ".join(context.get("price_bands", []))

    return f"""Sen bir mekan keşif asistanısın. Kullanıcının Türkçe sorgusunu yapılandırılmış filtreye çevir.

Kurallar:
- Sadece aşağıdaki listedeki lokasyon, kategori (product_tags) ve vibe etiketlerini kullan.
- Mekan uydurma; sadece filtre çıkar.
- Eşleşmeyen alanları boş bırak (null veya boş liste).
- price_band yalnızca kullanıcı fiyat belirttiyse doldur: {price_bands}
- Lokasyon kısaltmaları: "bahçeli" veya "bahceli" → Bahçelievler; "tunalı" → Tunalı

Mevcut lokasyonlar: {locations}
Mevcut kategoriler (product_tags): {product_tags}
Mevcut vibe etiketleri (vibe_tags): {vibe_tags}

Kullanıcı sorgusu: {query}"""
