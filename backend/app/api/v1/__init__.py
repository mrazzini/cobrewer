from fastapi import APIRouter

from app.api.v1 import admin, beans, brews, extract, recommendations, users

router = APIRouter(prefix="/api/v1")
router.include_router(beans.router)
router.include_router(brews.router)
router.include_router(recommendations.router)
router.include_router(extract.router)
router.include_router(users.router)
router.include_router(admin.router)
