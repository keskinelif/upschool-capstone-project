from enum import Enum

from pydantic import BaseModel, Field


class PriceBand(str, Enum):
    low = "₺"
    medium = "₺₺"
    high = "₺₺₺"


class TagType(str, Enum):
    vibe = "vibe"
    product = "product"


class ErrorResponse(BaseModel):
    detail: str


class Pagination(BaseModel):
    limit: int = Field(default=100, ge=1, le=200)
    offset: int = Field(default=0, ge=0)
