from enum import Enum

from pydantic import BaseModel, Field


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


class ImportResult(BaseModel):
    imported: int
    failed_rows: list[str]
