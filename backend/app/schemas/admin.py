from enum import Enum

from pydantic import BaseModel, Field

from app.schemas.review import ReviewResponse, ReviewStatus


class ModerationStatus(str, Enum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"


class ModerationItem(BaseModel):
    id: str
    user_id: str
    content_type: str
    content_url: str
    status: ModerationStatus = ModerationStatus.pending


class ModerationDecision(BaseModel):
    item_id: str
    status: ModerationStatus
    reason_code: str = Field(min_length=2, max_length=40)


class ReviewDecision(BaseModel):
    review_id: str
    status: ReviewStatus
    reason_code: str = Field(default="admin_decision", min_length=2, max_length=40)


class AdminPendingReview(ReviewResponse):
    venue_name: str


class ImportResult(BaseModel):
    imported: int
    failed_rows: list[str]
