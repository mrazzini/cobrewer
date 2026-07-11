from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.encoders import jsonable_encoder
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.api.v1 import router as v1_router
from app.db.session import engine


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    yield
    # Shutdown
    await engine.dispose()


app = FastAPI(
    title="Cobrewer API",
    description="The Coffee Brewing Co-pilot",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # TODO: restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(v1_router)


@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException) -> JSONResponse:
    # Keep every response in the {data, error, meta} envelope.
    return JSONResponse(
        status_code=exc.status_code,
        content={"data": None, "error": str(exc.detail), "meta": None},
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    details = jsonable_encoder(
        exc.errors(), custom_encoder={bytes: lambda b: b.decode(errors="replace")}
    )
    return JSONResponse(
        status_code=422,
        content={"data": None, "error": "Validation error", "meta": {"details": details}},
    )


@app.get("/health")
async def health():
    return {"status": "ok"}
