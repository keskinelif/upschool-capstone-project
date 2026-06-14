from pydantic import BaseModel, Field

from app.schemas.venue import VenueFilter, VenueResponse


class DiscoverRequest(BaseModel):
    query: str = Field(min_length=2, max_length=500)


class DiscoverResponse(BaseModel):
    filters: VenueFilter
    venues: list[VenueResponse]
    summary: str
    used_fallback: bool = False
