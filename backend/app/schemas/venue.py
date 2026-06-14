from pydantic import BaseModel, Field

from app.schemas.common import PriceBand


class VenueBase(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    area: str = Field(min_length=2, max_length=80)
    lat: float = Field(ge=-90, le=90)
    lng: float = Field(ge=-180, le=180)
    description: str = Field(default="", max_length=1200)
    tag_ids: list[str] = Field(default_factory=list)
    price_band: PriceBand
    image_url: str | None = Field(default=None, max_length=500)
    image_urls: list[str] = Field(default_factory=list, max_length=12)
    maps_url: str | None = Field(default=None, max_length=500)


class VenueCreate(VenueBase):
    pass


class VenueResponse(VenueBase):
    id: str


class VenueUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=120)
    area: str | None = Field(default=None, min_length=2, max_length=80)
    lat: float | None = Field(default=None, ge=-90, le=90)
    lng: float | None = Field(default=None, ge=-180, le=180)
    description: str | None = Field(default=None, max_length=1200)
    tag_ids: list[str] | None = None
    price_band: PriceBand | None = None
    image_url: str | None = Field(default=None, max_length=500)
    image_urls: list[str] | None = None
    maps_url: str | None = Field(default=None, max_length=500)


class VenueFilter(BaseModel):
    location: str | None = None
    product_tags: list[str] = Field(default_factory=list)
    vibe_tags: list[str] = Field(default_factory=list)
    price_band: PriceBand | None = None
