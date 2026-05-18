# MAGA Demo — Design Spec

A satirical text-adventure exercising:

- `convert_image_to_sprite` (real photo → 4-shade DMG sprite)
- Long branching dialogue with variable-driven endings
- English text width budget (~18 chars/line in default font)

## Protagonist sprite

- Source: `assets/source/trump.jpg` (downloaded by `scripts/download_assets.sh`, not committed)
- Pipeline: `convert_image_to_sprite(inputPath="assets/source/trump.jpg", animationType="fixed", name="Donald")`
- Result: one fixed-frame 16×16 sprite, 4 DMG greys, transparent BG
- Used in: every dialogue scene, sitting-static (no walk animation needed for a text adventure)

## Scenes

```
title ─→ rally ─→ debate ─→ press_room ─┬→ ending_landslide
                                        ├→ ending_recount
                                        └→ ending_concession
```

| Scene | Type | Purpose |
|---|---|---|
| `title` | LOGO | "PRESS START" |
| `rally` | ADVENTURE | Choice 1: bold promise vs. measured tone |
| `debate` | ADVENTURE | Choice 2: attack opponent vs. policy detail |
| `press_room` | ADVENTURE | Choice 3: dodge question vs. answer directly |
| `ending_*` | LOGO | One-screen ending text + "PRESS START" → `title` |

## Variables

| Symbol | Range | Initial | Why |
|---|---|---|---|
| `bold_score` | 0..6 | 0 | bold/dodge choices add 2 each |
| `policy_score` | 0..6 | 0 | measured/detail choices add 2 each |

## Ending selection

After Choice 3, run a script:

```
IF bold_score >= 4 → ending_landslide
ELSE IF policy_score >= 4 → ending_concession
ELSE → ending_recount
```

## Per-line width budget

GB Studio English default font ≈ 18 chars per line, max 4 lines per dialogue box. All lines below MUST be re-counted before commit.

### Sample dialogue (DRAFT — not yet width-checked)

> Rally — opening narration:
>
> ```
> The crowd roars.
> Cameras flash. You
> grip the podium and
> feel the weight of
> ```
> *(needs split across boxes — 4-line cap)*

### Choice 1 prompt:
> ```
> "Make America win
>  bigger than ever!"
> ```
> *(or)*
> ```
> "Let's outline the
>  plan: jobs, trade,
>  borders. Ready?"
> ```

(Claude will refine all dialogue lines against the width tool in the `dialogue-and-ui` skill before commit.)

## Open decisions

- Background art: `rally` and `press_room` should be hand-painted backgrounds in GB Studio editor; `debate` can reuse `press_room`.
- Music: skip in v1; add `assets/music/` later if scope allows.
- Length: ~3 choices is intentional v1 minimum; expand to 5–6 if width tests pass quickly.

## Tone & content guardrails

- No real names of opponents — "the opponent", "the press".
- No personal attacks; gameplay is about **rhetorical style**, not personal traits.
- Endings are absurdist (election landslide / hand-recount / concession-with-rematch-tease) — not factual claims.
