# Cobrewer Product Roadmap

Evidence-based roadmap. Sources: full-suite UX QA (web + API + Flutter, run against a live local stack, July 2026) and verified market research on the brewing-companion niche (Beanconqueror, BeanBook, Tasting Grounds, Filtru, coffee.cup.guru, Fellow/Aiden ecosystem, Trade Coffee).

> **Status review, 12 July 2026** (post System-B restyle, verified against a running stack): the restyle PR also shipped a large slice of Phase 0 and two Phase 1 items — checked off below. It additionally deleted this file; restored here with statuses. The top remaining launch blocker is unchanged: the seed library still attributes fabricated beans to real roasters.

## Positioning

**The closed loop nobody ships:** computed per-bean/per-grinder recommendations → brew log → community outcome data on the same bean → buy the bean. BeanBook has the AI journal + discovery, Tasting Grounds has the social layer, Beanconqueror has deep logging — no one has the loop, and no one has a deterministic dial-in engine backed by outcome data.

**Business reality (accepted):** nobody makes real money on brewing companion apps. Revenue, if it ever comes, is commerce-adjacent (bean referrals → integrated ordering; industry-sponsored visibility à la Untappd-for-Business). The app stays free and excellent for a long time; the near-term goal is trust and retention, not revenue.

**North-star metric:** weekly returning brewers (users who log ≥1 brew in ≥2 consecutive weeks). Everything below serves that number or protects the dataset that will feed ML.

---

## Phase 0 — Credibility & craft (gate for any public exposure)

The enthusiast community punishes sloppiness and never re-visits. Nothing goes to Reddit, app stores, or a public URL before this list is done.

**Data integrity (launch blocker):**
- [ ] Replace the seed library: it currently attributes ~200 fabricated beans with fabricated cupping scores to ~26 real roasters (Tim Wendelboe, Square Mile, Onyx, Sey…), all flagged `is_verified=true`. Options: (a) real catalog data with `source_url` per bean, entered from roaster sites; (b) clearly fictional roaster names; (c) tiny real starter set + lean on user submissions and bag-photo extraction. Never ship invented facts about real businesses.

**Broken-window fixes (from QA):**
- [x] Responsive nav + mobile layout — *done in restyle; verified no horizontal scroll on any page at 375px, nav fits.*
- [x] Brew-log bounds validation server-side (dose ≤200 g, yield ≤2000 g, temp ≤100 °C, time ≤7200 s, TDS ≤20, notes ≤2000 chars) — *done; absurd payloads now 422. Remaining sub-item below.*
- [ ] Reject fully-empty brew logs (bean + brewer with every measurement null still saves silently) and surface validation errors in the UI as friendly field-level messages, not a bare "Validation error" envelope string.
- [x] Explore pagination — *done; 100/page with a load-more control and honest counts.*
- [x] Mobile: Journal refreshes after logging — *done via refreshToken rebuild.*
- [x] Search: accent-insensitive — *done; `unaccent` migration 002, "atitlan" → "Atitlán" verified live.*
- [ ] Error states: bad/stale dial-in deep links still fail silently; double-submit guard on Log brew still missing.
- [ ] Remove or ship: landing page still promises "Snap the bag" with no extraction UI in any client. Until Phase 1 ships it, pull the card.
- [x] Copy/label polish — *done: journal shows "V60 / Pour Over", "unrated", "logged manually".*

**Foundations for everything later:**
- [ ] Minimal privacy-respecting analytics (retention, funnel: recommendation→log rate). Without this no roadmap decision can be evaluated.
- [ ] Data export (JSON/CSV) + account deletion. Privacy-sensitive niche, Beanconqueror sets the local-first bar, and export is a GDPR obligation (EU users from day one).
- [x] Mobile `generated_by` integrity — *done: label is "rules" only when the log still matches the fetched recipe.*

## Phase 1 — The co-pilot moat (the verified empty slot)

Nobody ships computed per-bean/per-grinder dial-in. This is the differentiator; make it undeniable.

- [x] Equipment-aware defaults: Dial-in preselects brewer/grinder from Profile — *done on web (free-text equipment mapped onto option keys); verify Flutter parity.*
- [ ] **The adjustment loop** — the actual "co-pilot" moment: after a rated brew, generate the next-brew delta ("rated 2★, notes say sour → go 2 clicks finer, +1 °C"). Rule-based v1 is enough; no competitor has any version of this.
- [ ] Grinder conversion, expanded and honest: more models, published conversion math, and a per-user calibration offset ("my JX runs coarse") — enthusiasts will loudly test these numbers.
- [ ] Bag-photo extraction UI (backend is done; BeanBook proves demand): camera/upload flow in web + Flutter, credits surfaced, extracted bean lands pre-filled in the add-bean form with `source_url`.
- [ ] In-brew experience: a brew timer on the recipe (even a simple one) — brewing happens with wet hands at a bench; a static recipe card abandons the user at the key moment. Filtru/Beanconqueror own this today.

## Phase 2 — Community & social proof (then Reddit)

Tasting Grounds proves social-alone doesn't scale (~2k installs); the differentiated version is social proof attached to the dial-in loop.

- [ ] Public per-bean pages: how many brews, best-rated recipe per brewer, aggregate ratings. Shareable URL (also the SEO surface — "how to brew [bean]" queries).
- [ ] Recipe sharing: one link from a logged brew → prefilled dial-in for the recipient.
- [x] Bean submission UI — *done early: /add-bean page shipped with the restyle.* Remaining: dedup-assist, visible verified/community badge on cards, moderation queue (user-generated beans = spam and trademark surface).
- [ ] Journal filters (bean/brewer/rating) and personal stats — the "your coffee journey, not lost" promise.
- [ ] **Reddit launch** (r/pourover, r/espresso, r/Coffee): "I built this" post, public changelog, feedback board. Founder responsiveness is the growth engine this niche rewards — budget ongoing hours, not a one-off post.

## Phase 3 — Commerce ramp (affiliate-first, checkout later)

Trade Coffee ($21M raised, 50+ roasters) proves the model is bean margin, not app fees — but it's commerce-first and US-only. Ramp in order of proof:

1. [ ] Outbound "Buy from roaster" links on bean pages (`source_url` already exists in the schema). Measure click-through — this number is the pitch deck for roasters.
2. [ ] Referral/affiliate codes with individual roasters where offered (Beanconqueror survives on the scale-equivalent of this).
3. [ ] Roaster profiles; let roasters claim their page and post drops (free at first — this seeds the Untappd-for-Business sponsorship model, the realistic "better than generic ads" play).
4. [ ] Integrated checkout only after traffic proves demand: most specialty roasters run Shopify (Storefront API), and physical goods are exempt from Apple's 30% cut. Mind EU/US shipping fragmentation — with an Italian founder and EU users, "order through the app" must be region-aware from design day one.

## Phase 4 — ML recommendations

Verified: as of mid-2025 the state of the art in "AI brew recommendations" is prompt-engineered LLMs over heuristics; nobody has trained on real outcome data. Keep the lane, but gate it:

- [ ] Enter only after Phase 0 validation has been live long enough that logs are clean, `generated_by` is trustworthy, and volume approaches the ~5,000-row target with rating coverage.
- [ ] Validate the honest question first: does a model beat the rules + adjustment loop on next-brew rating improvement? If not, the rules engine *is* the product; say so proudly.
- [ ] Expose TDS in the log form for the prosumer tail (schema and API now support it; no client shows it).

---

## Blind-spot register (things this plan could still be wrong about)

1. **Seed-data legal/reputational risk** — fabricated products under real roaster names (Phase 0 blocker, `scripts/data/beans.csv`). Survived the restyle untouched.
2. **Cost of free**: OpenAI vision, Neon, Railway scale with free users. The 3-credit cap helps; rate-limit unauthenticated surfaces and watch unit costs before any launch spike (a single Reddit front-page day is the stress test).
3. **Privacy as a feature, not just compliance**: the enthusiast crowd distrusts cloud lock-in (Beanconqueror is local-first). Export from day one; consider local-first sync as a differentiator later, not never.
4. **The brew-bench context**: our flows assume a person at a desk. Real usage is wet hands, 45 seconds, phone propped on a scale. Timer + big-type recipe view may matter more than any feature in Phase 2.
5. **Grinder conversion accuracy**: burr wear and unit variance make universal conversions wrong at the edges; without per-user calibration the community will (correctly) dunk on the numbers. Publish the math.
6. **Two-sided cold start**: the store thesis needs users before roasters care; affiliate click-through data is the bridge, but there is a real scenario where the audience stays 4-digit (Tasting Grounds) and commerce never activates. Decide now that the project is worth it anyway — the stated mission (brew memory that isn't lost, discovery without waste) survives that scenario.
7. **Solo-maintainer burnout**: Beanconqueror took 9 years of one person's evenings. Phases are sequenced so each stopping point is a coherent product; treat Phase 2 community obligations as recurring cost before committing.
8. **Untracked competition velocity**: BeanBook (indie, moving fast) is one loop short of this vision; the Aiden ecosystem shows how fast hobbyists fill gaps. Re-scan the landscape at each phase gate — this research goes stale in months.
9. **App-store friction unmodeled**: Apple review, dev accounts, Play data-safety forms, and the Flutter app's Clerk auth (still X-Dev-User only) are all between "prototype complete" and "installable" — budget it into Phase 2, not after.
10. **No measurement yet**: every claim above about what users want is inferred from competitors, not observed in Cobrewer. Phase 0 analytics exists to let the data overrule this document.
11. **Design-system drift vs. docs** (new, post-restyle): the brand moved from two-color flat to three-color neubrutalism ("System B"). CLAUDE.md and design/DESIGN.md are updated, but marketing copy, app-store screenshots, and any future mockups must follow one source of truth or the "AI-made sameness" problem returns as inconsistency.

## Non-goals (scope discipline)

- No paid subscription tier — the free price floor is set by Beanconqueror and freemium resentment is documented (Filtru reviews).
- No Bluetooth hardware integration until the core loop retains users — it's Beanconqueror's moat, device-by-device, and a solo-dev tar pit.
- No generic display ads, ever — brand-destroying with this audience; sponsorship = claimed roaster pages only.
- No ML before the data gates in Phase 4 — a bad recommender is worse than honest rules.
