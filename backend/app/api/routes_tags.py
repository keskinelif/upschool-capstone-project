from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import require_admin
from app.db.memory_store import new_id, store
from app.schemas.tag import TagCreate, TagResponse, TagUpdate

router = APIRouter(prefix="/tags", tags=["tags"])


@router.get("", response_model=list[TagResponse])
async def list_tags() -> list[TagResponse]:
    return [TagResponse(**tag) for tag in store.tags.values() if tag["is_active"]]


@router.post("", response_model=TagResponse, dependencies=[Depends(require_admin)])
async def create_tag(payload: TagCreate) -> TagResponse:
    tag_id = new_id()
    tag = {"id": tag_id, "name": payload.name, "type": payload.type, "is_active": True}
    store.tags[tag_id] = tag
    return TagResponse(**tag)


@router.patch("/{tag_id}", response_model=TagResponse, dependencies=[Depends(require_admin)])
async def update_tag(tag_id: str, payload: TagUpdate) -> TagResponse:
    tag = store.tags.get(tag_id)
    if not tag:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tag not found.")
    if payload.name is not None:
        tag["name"] = payload.name
    if payload.is_active is not None:
        tag["is_active"] = payload.is_active
    return TagResponse(**tag)
