# Cobrewer — The Coffee Brewing Co-pilot

## Project Overview
cobrewer is a specialty coffee brewing co-pilot that helps users dial in their brew parameters based on bean characteristics and their equipment. Users log brew results and rate them, building a personal dataset that will eventually power an ML recommendation engine. For now recommendations are rule-based.

## Brand
- Name: Cobrewer
- Theme: Retro, flat, playful — full-bleed color blocks, bold uppercase headings, no borders or gradients
- Colors (two-color palette): periwinkle #7185BF canvas (#6377B1 cards, #57699F wells), blush pink #ED99A4 as the single accent (buttons, stars, active states, the recipe card); cream #F7F4ED text on periwinkle, ink #333A63 text on pink
- Tone: knowledgeable coffee friend, not corporate

## Tech Stack
- Backend: FastAPI (Python 3.11), async SQLAlchemy, Alembic migrations, Pydantic v2
- Frontend: Next.js 15 App Router, Tailwind CSS, TypeScript
- Database: Neon PostgreSQL (async, connection string via DATABASE_URL env var)
- Auth: Clerk (frontend via @clerk/nextjs, backend validates Clerk JWT)
- File Storage: Cloudflare R2 (S3-compatible, boto3 client)
- AI: OpenAI API, gpt-4o-mini with vision for bag photo extraction
- Hosting: Railway (separate services for frontend and backend)
- CI/CD: GitHub Actions → Railway deploy on push to main

## Project Structure
cobrewer/
├── CLAUDE.md
├── .github/workflows/
│   ├── ci.yml
│   └── deploy.yml
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── config.py          # pydantic-settings, all env vars
│   │   ├── api/v1/
│   │   │   ├── beans.py
│   │   │   ├── brews.py
│   │   │   ├── recommendations.py
│   │   │   ├── extract.py     # bag photo → bean details
│   │   │   └── users.py
│   │   ├── services/
│   │   │   ├── recommendation_engine.py  # rule-based dial-in logic
│   │   │   ├── extraction_service.py     # OpenAI vision calls
│   │   │   └── storage_service.py        # Cloudflare R2
│   │   ├── db/
│   │   │   ├── models.py      # SQLAlchemy models
│   │   │   └── session.py     # async session factory
│   │   └── schemas/           # Pydantic request/response schemas
│   ├── migrations/            # Alembic
│   ├── scripts/
│   │   └── seed_beans.py      # seed ~200 beans from CSV
│   ├── Dockerfile
│   └── requirements.txt
└── frontend/
    ├── src/
    │   ├── app/               # Next.js App Router pages
    │   │   ├── page.tsx       # landing page
    │   │   ├── explore/       # bean discovery
    │   │   ├── dial-in/       # recommendation + brew log
    │   │   ├── journal/       # brew history
    │   │   └── profile/       # equipment setup
    │   ├── components/
    │   ├── hooks/
    │   └── lib/
    │       ├── api.ts         # typed fetch wrappers
    │       └── types.ts
    ├── Dockerfile
    └── package.json
└── mobile/                # Flutter app (Android/iOS + web preview), same API
    ├── lib/
    │   ├── main.dart      # bottom-nav shell: Explore, Dial-in, Journal, Profile
    │   ├── theme.dart     # cobra dark theme
    │   ├── constants.dart # brewer/grinder keys mirroring backend tables
    │   ├── api/client.dart    # envelope-aware client, X-Dev-User dev mode
    │   ├── models/models.dart
    │   ├── screens/
    │   └── widgets/
    ├── test/              # unit + widget tests against a faked backend
    └── pubspec.yaml       # deps: http only

## Database Models (design for ML future)
- users: id, clerk_id, display_name, created_at
- beans: id, name, roaster, origin, variety, process, roast_level, roast_date, tasting_notes (TEXT[]), cupping_score, source_url, created_by, is_verified
- brew_logs: id, user_id, bean_id, brewer, grinder, grind_setting, dose_g, yield_g, water_temp_c, brew_time_seconds, tds, rating (1-5), notes, generated_by ("rules"/"manual"), timestamp
- recommendations: id, bean_id, brewer, grinder, parameters (JSONB), generated_by, confidence_score
- user_equipment: id, user_id, equipment_type, brand, model, burr_type
- user_ai_credits: id, user_id, extractions_used, extractions_limit (3 free)

## Recommendation Engine Rules (rule-based v1)
Input: bean (origin, process, roast_level) + equipment (brewer, grinder)
Output: grind_setting_clicks, dose_g, ratio, water_temp_c, brew_time_range

Key rules:
- Light roast → higher water temp (93-96°C), finer grind than expected
- Natural process → coarser grind vs washed same roast level
- Espresso: dose 18-20g, ratio 1:2 to 1:2.5, 9 bar, 25-30s
- V60: dose 15g, ratio 1:16, 93°C, 3-3.5min
- French Press: dose 30g, ratio 1:15, 95°C, 4min
- Grind setting normalised to Comandante C40 clicks, then converted per grinder model

## API Endpoints
GET  /api/v1/beans?search=&origin=&process=&roast_level=
GET  /api/v1/beans/{id}
POST /api/v1/beans                    # user-submitted bean
GET  /api/v1/recommendations?bean_id=&brewer=&grinder=
POST /api/v1/brews                    # log a brew
GET  /api/v1/brews?user_id=           # brew history
POST /api/v1/extract/bag-photo        # AI extraction (costs 1 credit)
GET  /api/v1/users/me
PUT  /api/v1/users/me/equipment
GET  /health

## Environment Variables (backend)
DATABASE_URL=postgresql+asyncpg://...
CLERK_SECRET_KEY=
CLOUDFLARE_R2_ENDPOINT=
CLOUDFLARE_R2_ACCESS_KEY=
CLOUDFLARE_R2_SECRET_KEY=
CLOUDFLARE_R2_BUCKET=cobrewer-uploads
OPENAI_API_KEY=
DEBUG=false

## Environment Variables (frontend)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=
CLERK_SECRET_KEY=
NEXT_PUBLIC_API_URL=

## Key Engineering Decisions
- Rule-based engine now, schema designed to train ML model once brew_logs reach ~5000 rows
- Clerk handles all auth so zero custom auth code
- R2 over Azure Blob — no egress fees, S3-compatible, simpler
- Railway over Azure Container Apps — no MFA, no subscription drama, deploys in seconds
- gpt-4o-mini over gpt-4o — 15x cheaper, sufficient for structured JSON extraction from images
- Grind settings normalised to Comandante C40 as industry reference, converted per model

## Coding Standards
- Python: ruff for linting, black for formatting, type hints everywhere
- TypeScript: strict mode, no any
- All API responses use consistent envelope: {data, error, meta}
- All DB operations async
- Every endpoint has a corresponding Pydantic schema
- No hardcoded strings — all config via environment variables

## Current Phase
Prototype complete — full backend (auth, engine, endpoints, extraction, seed data), frontend (explore, dial-in, journal, profile), and Flutter mobile app with the same four flows, all working end-to-end. Now refining: deploy to Railway, production Clerk keys, bag-photo UI, journal filters. See README for the ordered list.

## Local Dev Mode
With DEBUG=true and no CLERK_SECRET_KEY, the backend accepts unauthenticated requests as a local dev identity (X-Dev-User header selects the user). Without NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY the frontend skips ClerkProvider entirely. The Flutter app always sends X-Dev-User (identity via --dart-define=DEV_USER) until a Clerk token provider is wired in. Zero secrets needed: `docker compose up --build`.