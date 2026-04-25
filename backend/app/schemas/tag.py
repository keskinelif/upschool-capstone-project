from pydantic import BaseModel, Field

from app.schemas.common import TagType


class TagCreate(BaseModel):
    name: str = Field(min_length=2, max_length=40)
    type: TagType


class TagUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=40)
    is_active: bool | None = None


class TagResponse(BaseModel):
    id: str
    name: str
    type: TagType
    is_active: bool
