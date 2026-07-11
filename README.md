# Cobrewer — The Coffee Brewing Co-pilot

Specialty coffee brewing co-pilot that helps you dial in brew parameters based on bean characteristics and your equipment. Log brews, rate them, and build a personal dataset that will eventually power ML-driven recommendations.

## Tech Stack

| Layer | Tech |
|-------|------|
| Backend | FastAPI, async SQLAlchemy, Alembic, Pydantic v2 |
| Frontend | Next.js 15 (App Router), Tailwind CSS, TypeScript |
| Mobile | Flutter (Android/iOS, plus a web target for local preview) |
| Database | Neon PostgreSQL (async) |
| Auth | Clerk (frontend + backend JWT validation) |
| Storage | Cloudflare R2 (S3-compatible) |
| AI | OpenAI gpt-4o-mini (bag photo extraction) |
| Hosting | Railway (frontend + backend services) |

## Current State

The full prototype is working end-to-end:

- **Backend** — beans CRUD with search/filters, rule-based recommendation engine (brewer baselines + roast/process adjustments, grind normalised to Comandante C40 clicks and converted per grinder), brew logging scoped to the authenticated user, Clerk JWT auth with a keyless dev mode, bag-photo extraction (gpt-4o-mini vision + R2 upload, 3 free credits), 200-bean seed library, 25 tests.
- **Frontend** — branded landing, Explore (search + filters), Dial-in (bean → equipment → recipe → log the brew), Journal, and Profile (equipment + AI credits). Works with or without Clerk keys.
- **Mobile** — Flutter app (`mobile/`) with the same four flows against the same API: Explore, Dial-in, Journal, Profile. 17 unit/widget tests against a faked backend.
- **Infra** — docker-compose stack, CI running lint + tests (with Postgres service) + typecheck + Flutter analyze/test.

## Next Up (refinement phase)

1. **Deploy** — `.github/workflows/deploy.yml` to Railway; restrict CORS; set real env vars.
2. **Clerk in production** — create the Clerk app, add keys, verify JWT flow end to end.
3. **Bag-photo UI** — frontend flow for `POST /api/v1/extract/bag-photo` (backend is done).
4. **Journal filters** — sort/filter brew history by bean, brewer, rating.
5. **Equipment-aware defaults** — Dial-in should preselect the grinder saved in Profile.
6. **CI/CD hardening** — pytest coverage, pre-commit hooks.
7. **ML prep** — once `brew_logs` reaches ~5000 rows, train a model to replace the rule-based engine.

## Local Development

Zero secrets needed for local dev: with `DEBUG=true` and no Clerk key, the backend substitutes a local dev identity (optionally set per-request with an `X-Dev-User` header) and the frontend renders without auth.

```bash
docker compose up --build
# frontend http://localhost:3000 · API http://localhost:8000 (docs at /docs)
```

Or run the pieces directly:

```bash
# Backend (needs a local Postgres with a `cobrewer` database)
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # defaults work for local dev; set DEBUG=true
alembic upgrade head
python -m scripts.seed_beans
uvicorn app.main:app --reload

# Frontend
cd frontend
npm install
npm run dev

# Backend tests (uses cobrewer_test database, or set TEST_DATABASE_URL)
cd backend && pytest

# Mobile (Flutter 3.32+; API URL defaults to http://localhost:8000)
cd mobile
flutter pub get
flutter run                # device/emulator — use --dart-define=API_URL=http://10.0.2.2:8000 on the Android emulator
flutter run -d web-server  # quick preview in a browser
flutter test
```

The mobile app reuses the backend's keyless dev mode: it always sends `X-Dev-User`
(override the identity with `--dart-define=DEV_USER=yourname`), and attaches a Clerk
bearer token instead once a token provider is wired in.

## Environment Variables

See `backend/.env.example` and `frontend/.env.example` for required variables.
