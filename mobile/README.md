# Cobrewer Mobile

Flutter client for Cobrewer — the coffee brewing co-pilot. Same four flows as
the web app (Explore, Dial-in, Journal, Profile) against the same FastAPI
backend.

## Run it

```bash
flutter pub get

# Against a local backend (DEBUG=true dev mode, no secrets needed):
flutter run

# Android emulator — 10.0.2.2 reaches the host machine:
flutter run --dart-define=API_URL=http://10.0.2.2:8000

# Quick preview in a browser:
flutter run -d web-server
```

## Build-time configuration (`--dart-define`)

| Define     | Default                 | Purpose                                                          |
| ---------- | ----------------------- | ---------------------------------------------------------------- |
| `API_URL`  | `http://localhost:8000` | Base URL of the Cobrewer backend.                                |
| `DEV_USER` | `mobile`                | Identity sent as `X-Dev-User` in the backend's keyless dev mode. |

The app always sends `X-Dev-User` until a Clerk token provider is wired into
`ApiClient.tokenProvider`; the backend ignores the header outside dev mode.

## Tests

```bash
flutter test        # unit + widget tests against a faked backend
flutter analyze
```

## Layout

```
lib/
├── main.dart          # bottom-nav shell: Explore, Dial-in, Journal, Profile
├── theme.dart         # Cobrewer palette (periwinkle/blush) + Material theme
├── constants.dart     # brewer/grinder keys mirroring the backend tables
├── api/client.dart    # envelope-aware HTTP client
├── models/models.dart # Dart mirrors of the backend Pydantic schemas
├── screens/
└── widgets/
```
