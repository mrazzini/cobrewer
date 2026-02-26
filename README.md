# Cobrewer — The Coffee Brewing Co-pilot

Specialty coffee brewing co-pilot that helps you dial in brew parameters based on bean characteristics and your equipment. Log brews, rate them, and build a personal dataset that will eventually power ML-driven recommendations.

## Tech Stack

| Layer | Tech |
|-------|------|
| Backend | FastAPI, async SQLAlchemy, Alembic, Pydantic v2 |
| Frontend | Next.js 15 (App Router), Tailwind CSS, TypeScript |
| Database | Neon PostgreSQL (async) |
| Auth | Clerk (frontend + backend JWT validation) |
| Storage | Cloudflare R2 (S3-compatible) |
| AI | OpenAI gpt-4o-mini (bag photo extraction) |
| Hosting | Railway (frontend + backend services) |

## Current State

The project scaffold is complete — directory structure, SQLAlchemy models (6 tables), Alembic initial migration, Pydantic schemas, FastAPI route stubs, and a Next.js frontend with Clerk auth wired in. All API endpoints return placeholder responses.

## Implementation Roadmap

### Phase 1 — Core Backend (next up)

1. **Beans CRUD endpoints** — Wire `list_beans`, `get_bean`, `create_bean` in `backend/app/api/v1/beans.py` with real SQLAlchemy queries. This is the foundation; everything else depends on beans existing in the DB.

2. **Rule-based Recommendation Engine** — Implement the logic in `backend/app/services/recommendation_engine.py` using the rules defined in CLAUDE.md (V60, espresso, French Press base parameters, roast-level adjustments, process adjustments, Comandante C40 click normalization).

3. **Clerk JWT auth middleware** — Create a FastAPI dependency that validates the Clerk JWT from the `Authorization` header, resolves `clerk_id` → `User`, and auto-creates users on first request. Protect all write endpoints.

4. **Brews CRUD endpoints** — Implement `POST /api/v1/brews` (log a brew) and `GET /api/v1/brews` (brew history) in `backend/app/api/v1/brews.py`.

5. **Recommendations endpoint** — Wire `GET /api/v1/recommendations` to call the recommendation engine and return parameters.

6. **Seed script** — Finish `backend/scripts/seed_beans.py` to load ~200 beans from a CSV so the app has real data.

### Phase 2 — Frontend Features

7. **Explore page** (`/explore`) — Bean discovery with search, origin/process/roast filters, and card-based results.

8. **Dial-in page** (`/dial-in`) — Select a bean + equipment, get recommendations, and log a brew in one flow.

9. **Journal page** (`/journal`) — Brew history with ratings, sortable/filterable.

10. **Profile page** (`/profile`) — Equipment setup (grinder, brewer) saved to `user_equipment`.

11. **Landing page** — Replace placeholder with branded hero, feature highlights, and sign-in CTA.

### Phase 3 — AI & Polish

12. **Bag photo extraction** — Implement `POST /api/v1/extract/bag-photo` using OpenAI vision to parse bean details from a photo. Enforce the 3-free-extraction credit limit.

13. **Cloudflare R2 storage** — Wire `backend/app/services/storage_service.py` for image uploads.

14. **docker-compose.yml** — Local dev setup with Postgres + backend + frontend.

15. **CI/CD hardening** — Add pytest coverage, pre-commit hooks, deploy workflow to Railway.

16. **ML prep** — Once `brew_logs` reaches ~5000 rows, train a model to replace the rule-based engine.

## Local Development

```bash
# Backend
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # fill in values
uvicorn app.main:app --reload

# Frontend
cd frontend
npm install
cp .env.example .env.local  # fill in values
npm run dev
```

## Environment Variables

See `backend/.env.example` and `frontend/.env.example` for required variables.
