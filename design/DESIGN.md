# Cobrewer Design System — "System B" (rounded neubrutalism)

Chosen 2026-07-12 after a mockup bake-off (see `mockups/`). The runner-up,
System C, is parked below for the record.

## Tokens

| Token | Value | Role |
|-------|-------|------|
| peri | `#7185BF` | canvas — every screen's background |
| cream | `#F7F4ED` | cards, inputs, nav surfaces |
| blush | `#ED99A4` | primary action: buttons, active filter chips, roast tags, stars |
| olive | `#B5B77A` | secondary accent: score badges, process tags, banners, active-nav text |
| ink | `#14162B` | text, 3px borders, hard shadows |
| white | `#FFFFFF` | neutral tag chips, stat tiles inside cards |

## Type

- **Display: Anton** — headings, bean names, buttons, stat values. Always
  uppercase, slight positive letter-spacing. Headlines get a 4px ink text-shadow
  on the periwinkle canvas.
- **Body: Rubik** — everything else, weights 400–800. Labels/meta run bold
  uppercase with letter-spacing.

## Shape & depth

- 3px solid ink borders on every surface.
- Hard offset shadows, zero blur: 6px 6px for cards, 3–4px for chips/buttons.
- Radii: cards 18–20px, buttons 14px, chips/pills/nav fully rounded (999px).
- Flat color only. No gradients, no soft shadows, no blur.
- Canvas texture: thin vertical cream pinstripes on the periwinkle
  background (2px wide, 28px apart, ~6% opacity) on both web and mobile.
- The mobile nav pill genuinely floats: content scrolls underneath it
  (scrollables reserve ~104px of bottom padding).

## Rules

- **No text symbols or emoji** — no `→`, `★`, `⌕` glyphs. All icons are drawn
  SVG (web) / vector icons or custom paints (Flutter). Ratings are SVG stars,
  blush fill + ink stroke when set, dim outline when unset.
- Color encodes meaning on tags: blush = roast level, olive = process,
  white = tasting notes.
- Pressed feedback compresses (scale ≈ 0.98) and never shifts layout;
  reduced-motion preferences disable it.
- Contrast: body text is ink on cream/white (≥ 12:1). Cream-on-peri text is
  reserved for large display type and bold labels.

## Parked: System C ("the kitchen")

Memphis-flavored alternative — cream `#FFF9F2` canvas, white cards with
rotating colored offset shadows (blush/peri/olive), Fredoka display +
Recursive casual body, geometric confetti decorations. Softer and more
readable in long sessions; lost on brand punch. Full four-screen mockup:
`mockups/mock-app-c.html` / `mock-app-c.png`. Revisit if System B proves
too loud in daily use — the two share the same palette DNA, so tokens
mostly transfer.
