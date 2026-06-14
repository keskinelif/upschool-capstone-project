from fastapi import APIRouter, HTTPException, status

from app.schemas.ai import DiscoverRequest, DiscoverResponse
from app.services.llm.discover import discover_venues

router = APIRouter(prefix="/ai", tags=["ai"])


@router.post("/discover", response_model=DiscoverResponse)
async def ai_discover(payload: DiscoverRequest) -> DiscoverResponse:
    try:
        filters, venues, summary, used_fallback = await discover_venues(payload.query)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(exc)) from exc

    return DiscoverResponse(
        filters=filters,
        venues=venues,
        summary=summary,
        used_fallback=used_fallback,
    )
