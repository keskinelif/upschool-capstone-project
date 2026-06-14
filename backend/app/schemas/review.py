from datetime import datetime, timezone
from enum import Enum

from pydantic import BaseModel, Field


class ReviewStatus(str, Enum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"


class ReviewCreate(BaseModel):
    venue_id: str
    text: str = Field(min_length=3, max_length=1200)


class ReviewResponse(BaseModel):
    id: str
    venue_id: str
    user_id: str
    username: str
    display_name: str
    text: str = Field(max_length=1200)
    status: ReviewStatus
    created_at: datetime
