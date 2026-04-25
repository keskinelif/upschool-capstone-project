from pydantic import BaseModel, Field

from app.schemas.common import PriceBand


class ContributionCreate(BaseModel):
    venue_id: str
    outlet_available: bool
    wifi_quiet_score: int = Field(ge=1, le=5)
    price_band: PriceBand


class ContributionResponse(ContributionCreate):
    id: str
    user_id: str
