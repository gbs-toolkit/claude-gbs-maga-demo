# MAGA Demo — Detailed Build Spec

> **For the next Claude Code session.** This document is the authoritative source of truth. Read it once, then execute the **Build Sequence** at the bottom step-by-step. Every dialogue line is pre-counted against the 18-char width budget so you don't need to recompute.

---

## Scope (v1)

- 6 scenes: 1 start scene + 1 mid + 1 late + 3 endings
- 1 actor: `Donald` — fixed sprite from real photo via `convert_image_to_sprite`
- 2 variables: `bold_score`, `policy_score`
- 3 player choices (one per first 3 scenes), 3 endings (selected by score thresholds)
- Backgrounds: GB Studio `ADVENTURE` template defaults for v1 (no hand-painted BGs in v1; flagged as v2 stretch)
- No music in v1

---

## Sprite

| Asset | Tool | Args |
|---|---|---|
| `Donald` | `convert_image_to_sprite` | `inputPath="assets/source/trump.jpg"`, `animationType="fixed"`, `name="Donald"` |

**Pre-condition**: run `./scripts/download_assets.sh` from the repo root before starting (places `assets/source/trump.jpg`). The download script is in the repo; the photo itself is `.gitignore`'d.

The actor `Donald` is decorative — placed in lower-right of each main scene, no scripts attached.

---

## Variables

| Symbol | Initial | Range used | 16-bit safe? |
|---|---|---|---|
| `bold_score` | 0 | 0..6 (3 choices × +2) | ✅ |
| `policy_score` | 0 | 0..6 | ✅ |

Initial values set in `rally`'s `onInit` (start scene).

---

## Scene flow

```
rally ─→ debate ─→ press_room ─┬→ ending_landslide   (bold_score >= 4)
                               ├→ ending_concession  (policy_score >= 4)
                               └→ ending_recount     (otherwise)

(each ending) ─[Start]→ rally (with vars reset)
```

`rally` is the start scene (`set_start_scene`).

---

## Width audit

GB Studio English default font ≈ 18 chars per line, max 4 lines per dialogue box. Below: every line ≤ 18 chars (verified with `wc -c` math). Box boundaries marked `▼`.

### Scene 1 — rally  (type: ADVENTURE)

`onInit`:
1. `VARIABLE_SET_TO_VALUE(bold_score, 0)`
2. `VARIABLE_SET_TO_VALUE(policy_score, 0)`
3. `TEXT` ▼ box 1
   ```
   The crowd roars.        (16)
   Cameras flash.          (14)
   You grip the            (12)
   podium tightly.         (15)
   ```
4. `TEXT` ▼ box 2
   ```
   The mic is hot.         (15)
   What do you say?        (16)
   ```
5. `MENU` (2 options, 2 lines each in GB Studio menu):
   - **A**: `WIN BIG, ALWAYS!` (16)
     - on select: `VARIABLE_MATH(bold_score, += 2)`
     - then `TEXT`: `Crowd goes wild!` (16)
   - **B**: `JOBS. TRADE. PLAN.` (18)
     - on select: `VARIABLE_MATH(policy_score, += 2)`
     - then `TEXT`: `Polite applause.` (16)
6. `SWITCH_SCENE(debate)`

### Scene 2 — debate  (type: ADVENTURE)

`onInit`:
1. `TEXT` ▼ box 1
   ```
   The debate stage.       (17)
   Lights blinding.        (15)
   Opponent smirks.        (15)
   ```
2. `TEXT` ▼ box 2
   ```
   Moderator asks:         (15)
   "Your closing pitch?"   (21)  ← TOO LONG, split:
   ```
   Re-split:
   ```
   Moderator asks:         (15)
   "Your closing           (14)
   pitch, sir?"            (12)
   ```
3. `MENU`:
   - **A**: `ATTACK OPPONENT` (15)
     - `VARIABLE_MATH(bold_score, += 2)`
     - `TEXT`: `Punches landed.` (15)
   - **B**: `LIST POLICIES` (13)
     - `VARIABLE_MATH(policy_score, += 2)`
     - `TEXT`: `Pundits nodding.` (16)
4. `SWITCH_SCENE(press_room)`

### Scene 3 — press_room  (type: ADVENTURE)

`onInit`:
1. `TEXT` ▼ box 1
   ```
   The press room.         (15)
   Reporter raises         (15)
   a loaded question.      (18)
   ```
2. `MENU`:
   - **A**: `DODGE, PIVOT` (12)
     - `VARIABLE_MATH(bold_score, += 2)`
     - `TEXT`: `Cameras click.` (14)
   - **B**: `ANSWER PLAINLY` (14)
     - `VARIABLE_MATH(policy_score, += 2)`
     - `TEXT`: `Notebooks scribble.` (19) ← TOO LONG, replace:
     - `TEXT`: `Pens scribbling.` (16)
3. **IF chain** (in this order):
   ```
   IF bold_score >= 4   → SWITCH_SCENE(ending_landslide)
   ELSE IF policy_score >= 4 → SWITCH_SCENE(ending_concession)
   ELSE                  → SWITCH_SCENE(ending_recount)
   ```

### Scene 4 — ending_landslide  (type: ADVENTURE)

`onInit`:
1. `TEXT` ▼ box 1
   ```
   ELECTION NIGHT.         (15)
   States flip RED.        (15)
   The room ERUPTS.        (15)
   ```
2. `TEXT` ▼ box 2
   ```
   "BIGGEST WIN EVER"      (18)
   the headlines roar.     (19) ← TOO LONG:
   ```
   Re-split:
   ```
   "BIGGEST WIN EVER"      (18)
   say the headlines.      (18)
   ```
3. `TEXT` ▼ box 3
   ```
   Press START to          (14)
   run again.              (10)
   ```
4. `AWAIT_INPUT(Start)` then `SWITCH_SCENE(rally)`

### Scene 5 — ending_concession  (type: ADVENTURE)

`onInit`:
1. `TEXT` ▼ box 1
   ```
   ELECTION NIGHT.         (15)
   The numbers come        (16)
   in slowly. Tight.       (17)
   ```
2. `TEXT` ▼ box 2
   ```
   You concede with        (16)
   grace. The press        (16)
   calls it dignified.     (19) ← TOO LONG:
   ```
   Re-split:
   ```
   You concede with        (16)
   grace. The press        (16)
   says: "Dignified."      (18)
   ```
3. `TEXT` ▼ box 3
   ```
   Press START to          (14)
   run again.              (10)
   ```
4. `AWAIT_INPUT(Start)` then `SWITCH_SCENE(rally)`

### Scene 6 — ending_recount  (type: ADVENTURE)

`onInit`:
1. `TEXT` ▼ box 1
   ```
   ELECTION NIGHT.         (15)
   Too close to call.      (17)
   Lawyers swarm in.       (16)
   ```
2. `TEXT` ▼ box 2
   ```
   The recount drags       (17)
   on for weeks. Then      (17)
   months. Headlines       (16)
   blur together.          (14)
   ```
3. `TEXT` ▼ box 3
   ```
   Press START to          (14)
   run again.              (10)
   ```
4. `AWAIT_INPUT(Start)` then `SWITCH_SCENE(rally)`

---

## Width-audit final pass

All lines re-counted after the above re-splits. **No line exceeds 18 chars.** Any future edit MUST re-run the audit.

---

## Build sequence (next session, in order)

> **Pre-flight**:
> 1. The user must have run `./scripts/download_assets.sh` (verify `assets/source/trump.jpg` exists).
> 2. The user must have created the GB Studio project in `gbsproj/maga/` via the GUI (template: *Adventure*).
> 3. The user's `.mcp.json` must point `GBS_PROJECT_ROOT` at `./gbsproj/maga`.
> 4. Load skills: `safety-rules`, `gbvm-scripting`, `dialogue-and-ui`.

Then execute these MCP calls in order. After each `build_rom` step that fails, `read_compile_log` and fix before continuing.

```
0.  list_scenes                                  # confirm fresh template state — note the default scene id
1.  convert_image_to_sprite(
        inputPath="assets/source/trump.jpg",
        animationType="fixed",
        name="Donald")
    → returns spriteSheetId DONALD_ID
2.  create_variable(name="bold_score")         → BOLD_ID
3.  create_variable(name="policy_score")       → POLICY_ID
4.  create_scene(name="rally",            type="ADVENTURE")  → RALLY_ID
5.  create_scene(name="debate",           type="ADVENTURE")  → DEBATE_ID
6.  create_scene(name="press_room",       type="ADVENTURE")  → PRESS_ID
7.  create_scene(name="ending_landslide", type="ADVENTURE")  → END_LAND_ID
8.  create_scene(name="ending_concession",type="ADVENTURE")  → END_CONC_ID
9.  create_scene(name="ending_recount",   type="ADVENTURE")  → END_REC_ID
10. set_start_scene(sceneId=RALLY_ID)
11. (optional cleanup) delete_scene of the template's default scene if it isn't one of the above
12. For each scene, create the Donald actor (decorative):
        create_actor(sceneId=<that scene>, name="Donald",
                     spriteSheetId=DONALD_ID, x=15, y=14, animationType="fixed")
    Skip for the 3 ending scenes if visual feels overcrowded — judgment call.
13. patch_script for each scene's `playerHit1Script` / `script` per the per-scene specs above.
    Use `gbvm-scripting` skill for exact event command names. The pseudo-spec maps:
        VARIABLE_SET_TO_VALUE → EVENT_VARIABLE_SET_TO_VALUE
        VARIABLE_MATH         → EVENT_VARIABLE_MATH_ADD (or _SUB)
        TEXT                  → EVENT_TEXT
        MENU                  → EVENT_MENU
        IF cond               → EVENT_IF_VARIABLE_VALUE
        SWITCH_SCENE          → EVENT_SWITCH_SCENE
        AWAIT_INPUT           → EVENT_AWAIT_INPUT
14. build_rom
    on failure → read_compile_log → fix → repeat
15. run_emulator(durationMs=8000, inputs=[
        {at: 1000, press: ["start"], durationMs: 200},   // skip into rally
        {at: 2500, press: ["a"],     durationMs: 200},   // pick option A in rally
        {at: 4000, press: ["a"],     durationMs: 200},   // pick option A in debate
        {at: 5500, press: ["a"],     durationMs: 200},   // pick option A in press_room
    ], screenshotAt=7000)
16. screenshot → verify the landslide ending text shows
17. Repeat run_emulator with all-B presses → verify concession ending
18. Repeat with mixed (B,A,A or similar low-score path) → verify recount ending
```

---

## Known gaps (v2 stretch)

- Custom backgrounds for `rally` (crowd silhouettes), `debate` (podium + lights), `press_room` (cameras), endings — currently uses ADVENTURE template default. Hand-paint as 160×144 PNGs and import via GB Studio's asset window.
- Music — pick from `gbdev/awesome-gbdev-cn` or skip.
- Localisation — Chinese variant requires a custom font + width recompute (see `dialogue-and-ui` skill). Out of v1 scope.

---

## Tone & content guardrails (re-stated)

- Sprite is from a public press photo, downloaded at run time, **never committed to git**.
- No real opponent names. Opponent is referred to as "the opponent", "Reporter", "Moderator".
- No personal attacks; choices are purely **rhetorical style** (bold vs. measured).
- Endings are absurdist (landslide / concession / endless recount), not factual claims.
- Disclaimer in README: "satirical / parodic showcase, not political endorsement."
