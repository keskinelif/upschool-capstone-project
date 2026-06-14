from abc import ABC, abstractmethod

from pydantic import BaseModel, Field

from app.schemas.common import PriceBand


class DiscoverFilters(BaseModel):
    location: str | None = None
    product_tags: list[str] = Field(default_factory=list)
    vibe_tags: list[str] = Field(default_factory=list)
    price_band: PriceBand | None = None


class LlmProvider(ABC):
    @abstractmethod
    def parse_discover_query(self, query: str, context: dict) -> DiscoverFilters:
        """Parse a natural-language discover query into structured filters."""
