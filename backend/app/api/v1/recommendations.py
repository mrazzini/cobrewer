import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Bean, Recommendation
from app.db.session import get_session
from app.schemas.base import ApiResponse
from app.schemas.recommendations import RecommendationOut
from app.services.recommendation_engine import UnsupportedBrewerError, get_recommendation

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.get("", response_model=ApiResponse)
async def get_recommendations(
    bean_id: uuid.UUID = Query(...),
    brewer: str = Query(...),
    grinder: str | None = Query(None),
    session: AsyncSession = Depends(get_session),
) -> ApiResponse:
    bean = await session.get(Bean, bean_id)
    if bean is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Bean not found")

    try:
        result = get_recommendation(
            origin=bean.origin,
            process=bean.process,
            roast_level=bean.roast_level,
            brewer=brewer,
            grinder=grinder,
        )
    except UnsupportedBrewerError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(exc)
        ) from exc

    recommendation = Recommendation(
        bean_id=bean.id,
        brewer=result["parameters"]["brewer"],
        grinder=grinder,
        parameters=result["parameters"],
        generated_by=result["generated_by"],
        confidence_score=result["confidence_score"],
    )
    session.add(recommendation)
    await session.commit()
    await session.refresh(recommendation)
    return ApiResponse(
        data=RecommendationOut.model_validate(recommendation).model_dump(mode="json")
    )
