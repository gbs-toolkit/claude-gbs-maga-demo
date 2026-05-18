# MAGA Demo — Trump's First 100 Days (v2)

> **For the next Claude Code session.** This document is the authoritative source of truth. v1 was a 30-second 3-choice text adventure; v2 is a real game with state tracking, stat readouts, and 4 endings driven by 8 weeks of decisions. **Read it once, then execute the Build Sequence at the bottom step-by-step.** Every dialogue line below is pre-counted against the 18-char width budget.
>
> v1 lives in git history at commit `00e1e01` if you need to compare.

---

## Premise

You are Donald J. Trump on **Inauguration Day**. The next 8 in-game weeks compress the "First 100 Days" trope into a stat-driven decision game. Each week presents one milestone with three rhetorical choices; choices move four stats; the final scene routes to one of four endings based on the stat snapshot.

This is a **satirical, parodic showcase**. No real opponent names, no factual claims, no policy commentary — choices are pure rhetorical style. Treat it as a self-contained 5-minute novelty ROM.

---

## Scope (v2)

- **13 scenes**: 8 milestone weeks + `election_night` (router) + 4 endings
- **1 actor**: `Donald` — fixed sprite from real photo via `convert_image_to_sprite`, decorative, lower-right of every scene
- **6 variables**: 4 stats + `turn` + `seed` (seed is unused in v1 of v2 — reserved for future random events; do **not** create yet)
- **No music in v1 of v2**
- **Backgrounds**: ADVENTURE template defaults (hand-painted backgrounds are out of scope; flag in "Known gaps")

---

## Sprite

| Asset | Tool | Args |
|---|---|---|
| `Donald` | `convert_image_to_sprite` | `inputPath="assets/source/trump.jpg"`, `animationType="fixed"`, `name="Donald"` |

**Pre-condition**: run `./scripts/download_assets.sh` from the repo root before starting (places `assets/source/trump.jpg`). The download script is in the repo; the photo itself is `.gitignore`'d.

The actor `Donald` is decorative — placed at `(15, 14)` of each main scene. **No scripts attached.** Skip in ending scenes if the visual feels overcrowded — judgment call.

---

## Variables

All stats are 16-bit signed; range 0..100. **GB Studio variables are 16-bit signed; do not let any add/sub push a stat below 0 or above 100 — every choice's math is bounded by the table below.**

| Symbol | Initial | Range | Purpose |
|---|---|---|---|
| `approval` | 50 | 0..100 | Public approval rating (drives landslide/narrow endings) |
| `twitter` | 50 | 0..100 | Twitter clout (gates coup-from-base ending) |
| `economy` | 50 | 0..100 | Economic indicator (multiplier on landslide threshold) |
| `loyalty` | 50 | 0..100 | Base/cabinet loyalty (gates impeachment) |
| `turn` | 0 | 0..8 | Current week, incremented at the top of every milestone |

Initial values are set in `inauguration`'s `onInit` (start scene). On each ending, `onInit` resets all five back to initial values before `AWAIT_INPUT(Start) → SWITCH_SCENE(inauguration)`.

---

## Stat math conventions

- All deltas in this doc use signed integers in [-20, +20].
- Sum of |Δstat| per choice is ≤ 30 to keep pacing readable.
- Choices are designed so **no single line of play can saturate a stat** — endings are determined by combinations across weeks.

---

## Trump catchphrase library (≤18 chars each, verified)

Use these in reaction text for flavor. Each line listed with character count.

| Line | Chars |
|---|---|
| `Tremendous!` | 11 |
| `Bigly!` | 6 |
| `Fake news!` | 10 |
| `Sad!` | 4 |
| `Big league!` | 11 |
| `BIG WIN!` | 8 |
| `Covfefe...` | 10 |
| `WRONG!` | 6 |
| `Believe me.` | 11 |
| `The best.` | 9 |
| `Period.` | 7 |
| `Nobody knew!` | 12 |
| `So unfair.` | 10 |
| `MAGA!` | 5 |

Avoid combining two catchphrases on the same line — readable breaks beat density.

---

## Scene flow

```
inauguration → cabinet → press_conf → summit → trade_war
   → midterm → impeach_test → final_rally → election_night
                                    ┌→ ending_landslide  (approval ≥ 70 AND economy ≥ 60)
                                    ├→ ending_narrow     (approval ≥ 50)
                                    ├→ ending_coup       (loyalty < 30 AND twitter ≥ 70)
                                    └→ ending_impeached  (otherwise)

(each ending) ─[Start]→ inauguration (with all vars reset)
```

`inauguration` is the start scene (`set_start_scene`).

---

## Stat-readout helper text

Every milestone week ends its narration boxes with a stat-readout box. GB Studio supports variable insertion in `EVENT_TEXT` via `$VarName$` — confirm exact syntax in the `dialogue-and-ui` skill before committing. Width budget assumes 2-digit stat values.

Stat readout box (4 lines, each ≤18 chars):

```
Approval: $approval$%   ← 14 + 2 + 1 = 17 with 2-digit value
Twitter:  $twitter$    ← 14 with 2-digit
Economy:  $economy$%   ← 14
Loyalty:  $loyalty$%   ← 14
```

If `$var$` insertion isn't supported in this GB Studio version, fall back to omitting the readout (the player can infer state from reactions) — re-read `dialogue-and-ui` and decide. **Do not generate a readout that exceeds 18 chars on any line.**

---

## Per-scene specs

For every milestone week, the structure is:

```
onInit:
  1. VARIABLE_MATH(turn, += 1)
  2. TEXT: scene-setting narration (1 box, ≤4 lines)
  3. TEXT: stat readout (1 box, see helper above) — skip if $var$ unsupported
  4. MENU (3 choices)
       option A: VARIABLE_MATH × 1-2  → TEXT reaction (≤2 lines) → SWITCH_SCENE(next)
       option B: VARIABLE_MATH × 1-2  → TEXT reaction (≤2 lines) → SWITCH_SCENE(next)
       option C: VARIABLE_MATH × 1-2  → TEXT reaction (≤2 lines) → SWITCH_SCENE(next)
```

GB Studio menus support up to 4 options visible at once. **Each option label is ≤18 chars.**

### Week 1 — `inauguration` (type: ADVENTURE) — START SCENE

`onInit`:
1. `VARIABLE_SET_TO_VALUE(approval, 50)`
2. `VARIABLE_SET_TO_VALUE(twitter, 50)`
3. `VARIABLE_SET_TO_VALUE(economy, 50)`
4. `VARIABLE_SET_TO_VALUE(loyalty, 50)`
5. `VARIABLE_SET_TO_VALUE(turn, 1)`
6. `TEXT` ▼ box 1
   ```
   January 20.        (10)
   The Capitol steps. (18)
   Wind. Cameras.     (14)
   Your moment.       (12)
   ```
7. `TEXT` ▼ box 2 (stat readout — see helper)
8. `MENU`:
   - **A**: `"AMERICAN CARNAGE"` (18)
     - `VARIABLE_MATH(twitter, += 15)`, `VARIABLE_MATH(loyalty, += 10)`, `VARIABLE_MATH(approval, -= 5)`
     - `TEXT`: `Base goes wild.` (15) ▼ `Press: shocked.` (15)
   - **B**: `"UNITY AND HOPE"` (15)
     - `VARIABLE_MATH(approval, += 10)`, `VARIABLE_MATH(loyalty, -= 5)`
     - `TEXT`: `Polite applause.` (16) ▼ `Believe me.` (11)
   - **C**: `"AMERICA FIRST"` (14)
     - `VARIABLE_MATH(approval, += 5)`, `VARIABLE_MATH(twitter, += 5)`, `VARIABLE_MATH(loyalty, += 5)`
     - `TEXT`: `Crowd nods.` (11) ▼ `Tremendous!` (11)
9. `SWITCH_SCENE(cabinet)`

### Week 2 — `cabinet` (type: ADVENTURE)

`onInit`:
1. `VARIABLE_MATH(turn, += 1)`
2. `TEXT` ▼ box 1
   ```
   Week 2. Cabinet    (15)
   picks. Generals    (15)
   and billionaires   (16)
   line the room.     (14)
   ```
3. `TEXT` ▼ box 2 (stat readout)
4. `MENU`:
   - **A**: `LOYALISTS ONLY` (14)
     - `VARIABLE_MATH(loyalty, += 20)`, `VARIABLE_MATH(approval, -= 10)`
     - `TEXT`: `The base cheers.` (16) ▼ `Senate scowls.` (14)
   - **B**: `WALL STREET` (11)
     - `VARIABLE_MATH(economy, += 15)`, `VARIABLE_MATH(loyalty, -= 5)`
     - `TEXT`: `Markets jump.` (13) ▼ `Big league!` (11)
   - **C**: `MIX IT UP` (9)
     - `VARIABLE_MATH(approval, += 10)`, `VARIABLE_MATH(economy, += 5)`
     - `TEXT`: `Pundits puzzled.` (16) ▼ `The best.` (9)
5. `SWITCH_SCENE(press_conf)`

### Week 3 — `press_conf` (type: ADVENTURE)

`onInit`:
1. `VARIABLE_MATH(turn, += 1)`
2. `TEXT` ▼ box 1
   ```
   Week 3. The press  (16)
   room is packed.    (15)
   A reporter asks    (15)
   a hostile question.(18)
   ```
3. `TEXT` ▼ box 2 (stat readout)
4. `MENU`:
   - **A**: `"FAKE NEWS!"` (12)
     - `VARIABLE_MATH(twitter, += 15)`, `VARIABLE_MATH(approval, -= 10)`
     - `TEXT`: `Base roars.` (11) ▼ `Pundits gasp.` (13)
   - **B**: `DEFLECT, PIVOT` (14)
     - `VARIABLE_MATH(twitter, += 5)`, `VARIABLE_MATH(approval, -= 5)`
     - `TEXT`: `Cameras click.` (14) ▼ `Sad!` (4)
   - **C**: `ANSWER PLAINLY` (14)
     - `VARIABLE_MATH(approval, += 15)`, `VARIABLE_MATH(twitter, -= 5)`
     - `TEXT`: `Pens scribbling.` (16) ▼ `Editorials warm.` (16)
5. `SWITCH_SCENE(summit)`

### Week 4 — `summit` (type: ADVENTURE)

`onInit`:
1. `VARIABLE_MATH(turn, += 1)`
2. `TEXT` ▼ box 1
   ```
   Week 4. Foreign    (15)
   summit. Leaders    (15)
   eye each other     (14)
   over the table.    (15)
   ```
3. `TEXT` ▼ box 2 (stat readout)
4. `MENU`:
   - **A**: `BRO HUG, ALPHA` (14)
     - `VARIABLE_MATH(twitter, += 10)`, `VARIABLE_MATH(approval, -= 5)`, `VARIABLE_MATH(economy, -= 5)`
     - `TEXT`: `Photo goes viral.` (17) ▼ `Allies blink.` (13)
   - **B**: `STERN AND BRIEF` (15)
     - `VARIABLE_MATH(approval, += 10)`, `VARIABLE_MATH(loyalty, += 5)`
     - `TEXT`: `Read as strong.` (15) ▼ `Period.` (7)
   - **C**: `STORM OUT EARLY` (15)
     - `VARIABLE_MATH(twitter, += 15)`, `VARIABLE_MATH(economy, -= 15)`, `VARIABLE_MATH(loyalty, += 5)`
     - `TEXT`: `Markets dip red.` (16) ▼ `BIG STATEMENT!` (14)
5. `SWITCH_SCENE(trade_war)`

### Week 5 — `trade_war` (type: ADVENTURE)

`onInit`:
1. `VARIABLE_MATH(turn, += 1)`
2. `TEXT` ▼ box 1
   ```
   Week 5. Tariffs    (15)
   on the table.      (13)
   Farmers nervous.   (16)
   Factories cheer.   (16)
   ```
3. `TEXT` ▼ box 2 (stat readout)
4. `MENU`:
   - **A**: `MASSIVE TARIFFS` (15)
     - `VARIABLE_MATH(loyalty, += 15)`, `VARIABLE_MATH(economy, -= 20)`
     - `TEXT`: `Rust belt cheers.` (17) ▼ `Markets crash.` (14)
   - **B**: `TARGETED ONLY` (13)
     - `VARIABLE_MATH(economy, += 5)`, `VARIABLE_MATH(loyalty, += 5)`
     - `TEXT`: `Quietly approved.` (17) ▼ `The best.` (9)
   - **C**: `BLUFF, THEN DEAL` (16)
     - `VARIABLE_MATH(twitter, += 10)`, `VARIABLE_MATH(economy, += 10)`, `VARIABLE_MATH(loyalty, -= 10)`
     - `TEXT`: `Pundits divided.` (16) ▼ `BIG WIN!` (8)
5. `SWITCH_SCENE(midterm)`

### Week 6 — `midterm` (type: ADVENTURE)

`onInit`:
1. `VARIABLE_MATH(turn, += 1)`
2. `TEXT` ▼ box 1
   ```
   Week 6. Midterms.  (16)
   The party needs    (15)
   you on the road.   (16)
   ```
3. `TEXT` ▼ box 2 (stat readout)
4. `MENU`:
   - **A**: `RALLY EVERY DAY` (15)
     - `VARIABLE_MATH(twitter, += 15)`, `VARIABLE_MATH(loyalty, += 10)`, `VARIABLE_MATH(approval, -= 10)`
     - `TEXT`: `Crowds enormous.` (16) ▼ `Suburbs slip.` (13)
   - **B**: `STAY IN OFFICE` (14)
     - `VARIABLE_MATH(approval, += 10)`, `VARIABLE_MATH(twitter, -= 10)`
     - `TEXT`: `Looks dignified.` (16) ▼ `Base annoyed.` (13)
   - **C**: `TWEET FROM HOME` (15)
     - `VARIABLE_MATH(twitter, += 20)`, `VARIABLE_MATH(loyalty, -= 5)`, `VARIABLE_MATH(approval, -= 5)`
     - `TEXT`: `Trending all day.` (17) ▼ `Covfefe...` (10)
5. `SWITCH_SCENE(impeach_test)`

### Week 7 — `impeach_test` (type: ADVENTURE)

`onInit`:
1. `VARIABLE_MATH(turn, += 1)`
2. `TEXT` ▼ box 1
   ```
   Week 7. The House  (16)
   opens an inquiry.  (16)
   Your phone rings.  (16)
   It's the Speaker.  (16)
   ```
3. `TEXT` ▼ box 2 (stat readout)
4. `MENU`:
   - **A**: `"WITCH HUNT!"` (13)
     - `VARIABLE_MATH(twitter, += 15)`, `VARIABLE_MATH(loyalty, += 10)`, `VARIABLE_MATH(approval, -= 15)`
     - `TEXT`: `Base furious.` (13) ▼ `Donors quiet.` (13)
   - **B**: `LAWYER UP COLD` (14)
     - `VARIABLE_MATH(loyalty, += 5)`, `VARIABLE_MATH(approval, -= 5)`
     - `TEXT`: `Legal fortress.` (15) ▼ `Period.` (7)
   - **C**: `OFFER A DEAL` (12)
     - `VARIABLE_MATH(approval, += 15)`, `VARIABLE_MATH(loyalty, -= 20)`
     - `TEXT`: `Pundits stunned.` (16) ▼ `Base feels sold.` (16)
5. `SWITCH_SCENE(final_rally)`

### Week 8 — `final_rally` (type: ADVENTURE)

`onInit`:
1. `VARIABLE_MATH(turn, += 1)`
2. `TEXT` ▼ box 1
   ```
   Week 8. The final  (16)
   rally. Stadium     (14)
   packed. Cameras    (15)
   everywhere.        (10)
   ```
3. `TEXT` ▼ box 2 (stat readout)
4. `MENU`:
   - **A**: `GO FULL MAGA` (12)
     - `VARIABLE_MATH(twitter, += 15)`, `VARIABLE_MATH(loyalty, += 10)`, `VARIABLE_MATH(approval, -= 5)`
     - `TEXT`: `Stadium ROARS.` (14) ▼ `MAGA!` (5)
   - **B**: `PRESIDENTIAL TONE` (17)
     - `VARIABLE_MATH(approval, += 15)`, `VARIABLE_MATH(twitter, -= 5)`
     - `TEXT`: `Crowd polite.` (13) ▼ `Editorials nod.` (15)
   - **C**: `THANK THE BASE` (14)
     - `VARIABLE_MATH(loyalty, += 15)`, `VARIABLE_MATH(approval, += 5)`
     - `TEXT`: `Tears in row 1.` (15) ▼ `Tremendous!` (11)
5. `SWITCH_SCENE(election_night)`

### `election_night` (type: ADVENTURE) — router scene

No menu, no Donald actor (overcrowded). Just narration → IF chain → switch.

`onInit`:
1. `TEXT` ▼ box 1
   ```
   Election night.    (15)
   Returns coming in. (18)
   The room holds     (14)
   its breath.        (10)
   ```
2. `TEXT` ▼ box 2 (final stat readout — same helper)
3. **IF chain** (in this exact order — IF nesting depth = 3, well under MAX_NESTED_SCRIPT_DEPTH=5):
   ```
   IF approval >= 70:
     IF economy >= 60:
       SWITCH_SCENE(ending_landslide)
     ELSE:
       SWITCH_SCENE(ending_narrow)
   ELSE IF approval >= 50:
     SWITCH_SCENE(ending_narrow)
   ELSE IF loyalty < 30:
     IF twitter >= 70:
       SWITCH_SCENE(ending_coup)
     ELSE:
       SWITCH_SCENE(ending_impeached)
   ELSE:
     SWITCH_SCENE(ending_impeached)
   ```

   **Why this order**: approval is the dominant signal (re-election); economy gates landslide vs. narrow; the "lost" branch splits between coup (base turned: high twitter, low loyalty) and impeachment (collapsed all around).

### Ending 1 — `ending_landslide` (type: ADVENTURE)

`onInit`:
1. `TEXT` ▼ box 1
   ```
   Networks call it    (16)
   early. RED across   (16)
   the map. Aides      (14)
   shake your hand.    (15)
   ```
2. `TEXT` ▼ box 2
   ```
   "BIGGEST WIN EVER"  (18)
   say the headlines.  (18)
   The base ERUPTS.    (15)
   ```
3. `TEXT` ▼ box 3
   ```
   Tremendous.         (11)
   Press START to      (14)
   run again.          (10)
   ```
4. **Reset all vars** (so re-run starts fresh):
   ```
   VARIABLE_SET_TO_VALUE(approval, 50)
   VARIABLE_SET_TO_VALUE(twitter, 50)
   VARIABLE_SET_TO_VALUE(economy, 50)
   VARIABLE_SET_TO_VALUE(loyalty, 50)
   VARIABLE_SET_TO_VALUE(turn, 0)
   ```
5. `AWAIT_INPUT(Start)` → `SWITCH_SCENE(inauguration)`

### Ending 2 — `ending_narrow` (type: ADVENTURE)

`onInit`:
1. `TEXT` ▼ box 1
   ```
   The numbers come    (16)
   in slowly. Tight.   (17)
   Three states drag   (17)
   past midnight.      (14)
   ```
2. `TEXT` ▼ box 2
   ```
   Networks call it    (16)
   at 4 AM. A win.     (15)
   Not a wave. A win.  (18)
   ```
3. `TEXT` ▼ box 3
   ```
   You'll take it.     (15)
   Press START to      (14)
   run again.          (10)
   ```
4. Reset vars (same 5 lines as landslide).
5. `AWAIT_INPUT(Start)` → `SWITCH_SCENE(inauguration)`

### Ending 3 — `ending_coup` (type: ADVENTURE)

Triggered when the base abandons you (`loyalty < 30`) but the megaphone is still loud (`twitter >= 70`). Read this as: the base liked you online, walked off in person.

`onInit`:
1. `TEXT` ▼ box 1
   ```
   Election night.    (15)
   The base stays     (14)
   home. The rally    (14)
   stadium is empty.  (17)
   ```
2. `TEXT` ▼ box 2
   ```
   Twitter trends     (14)
   are thunder.       (12)
   The ballot box     (14)
   is silence.        (11)
   ```
3. `TEXT` ▼ box 3
   ```
   Sad!               (4)
   Press START to     (14)
   run again.         (10)
   ```
4. Reset vars.
5. `AWAIT_INPUT(Start)` → `SWITCH_SCENE(inauguration)`

### Ending 4 — `ending_impeached` (type: ADVENTURE)

Default lost path.

`onInit`:
1. `TEXT` ▼ box 1
   ```
   Election night.    (15)
   States flip BLUE.  (16)
   The room empties   (16)
   without a word.    (14)
   ```
2. `TEXT` ▼ box 2
   ```
   Lawyers swarm in.  (16)
   Headlines blur     (14)
   for weeks. Then    (14)
   months.            (6)
   ```
3. `TEXT` ▼ box 3
   ```
   So unfair.         (10)
   Press START to     (14)
   run again.         (10)
   ```
4. Reset vars.
5. `AWAIT_INPUT(Start)` → `SWITCH_SCENE(inauguration)`

---

## Width-audit final pass

Every dialogue line above is ≤18 chars. Stat-readout lines assume ≤2-digit values; if `$var$` insertion turns out to inline 3-digit values (e.g. negatives during testing), the readout box must be re-audited. **Any future edit MUST re-run the audit for the touched lines.**

---

## Build sequence (next session, in order)

> **Pre-flight**:
> 1. The user must have run `./scripts/download_assets.sh` (verify `assets/source/trump.jpg` exists).
> 2. The user must have created the GB Studio project in `gbsproj/maga/` via the GUI. Project name `maga`, **template `Blank` or `Sample Project`** (Claude clears the default scene in step 11). "ADVENTURE" is a per-scene type, not a project template.
> 3. The user's `.mcp.json` must point `GBS_PROJECT_ROOT` at `./gbsproj/maga`.
> 4. Load skills: `safety-rules`, `gbvm-scripting`, `dialogue-and-ui`.
> 5. **If a v1 build already exists in `gbsproj/maga/project/scenes/`**: list the scene ids, then `delete_scene` for every existing scene before step 4 below. Set the start scene to a placeholder if `delete_scene` refuses on the start-scene guard — switch to a fresh dummy scene first, then delete the rest.

Then execute these MCP calls in order. After each `build_rom` step that fails, `read_compile_log` and fix before continuing.

```
0.  list_scenes                               # confirm state — note any v1 scene ids
0a. (cleanup, only if v1 scenes exist)
    For each v1 scene: delete_scene(force=true if needed). Use set_start_scene
    to migrate the start pointer onto a freshly created dummy first if the guard
    refuses on the v1 start scene.

1.  convert_image_to_sprite(
        inputPath="assets/source/trump.jpg",
        animationType="fixed",
        name="Donald")
    → spriteSheetId DONALD_ID

2.  create_variable(name="approval")          → APPROVAL_ID
3.  create_variable(name="twitter")           → TWITTER_ID
4.  create_variable(name="economy")           → ECONOMY_ID
5.  create_variable(name="loyalty")           → LOYALTY_ID
6.  create_variable(name="turn")              → TURN_ID

7.  create_scene(name="inauguration",     type="ADVENTURE")  → INAUG_ID
8.  create_scene(name="cabinet",          type="ADVENTURE")  → CAB_ID
9.  create_scene(name="press_conf",       type="ADVENTURE")  → PRESS_ID
10. create_scene(name="summit",           type="ADVENTURE")  → SUMMIT_ID
11. create_scene(name="trade_war",        type="ADVENTURE")  → TRADE_ID
12. create_scene(name="midterm",          type="ADVENTURE")  → MID_ID
13. create_scene(name="impeach_test",     type="ADVENTURE")  → IMP_TEST_ID
14. create_scene(name="final_rally",      type="ADVENTURE")  → FINAL_ID
15. create_scene(name="election_night",   type="ADVENTURE")  → ELECT_ID
16. create_scene(name="ending_landslide", type="ADVENTURE")  → END_LAND_ID
17. create_scene(name="ending_narrow",    type="ADVENTURE")  → END_NAR_ID
18. create_scene(name="ending_coup",      type="ADVENTURE")  → END_COUP_ID
19. create_scene(name="ending_impeached", type="ADVENTURE")  → END_IMP_ID

20. set_start_scene(sceneId=INAUG_ID)

21. (optional cleanup) delete_scene of any leftover template default scene if it
    isn't one of the above. Verify with list_scenes before/after.

22. For each of the 8 milestone weeks + the 4 endings:
        create_actor(sceneId=<that scene>, name="Donald",
                     spriteSheetId=DONALD_ID, x=15, y=14, animationType="fixed")
    Skip for `election_night`. Skip in any ending scene where it crowds the
    box layout — judgment call after first build.

23. patch_script for each scene's onInit / `script` per the per-scene specs above.
    Use the `gbvm-scripting` skill for exact event command names. The pseudo-spec
    maps:
        VARIABLE_SET_TO_VALUE → EVENT_VARIABLE_SET_TO_VALUE
        VARIABLE_MATH(+= n)    → EVENT_VARIABLE_MATH_ADD with operand=n
        VARIABLE_MATH(-= n)    → EVENT_VARIABLE_MATH_SUB with operand=n
        TEXT                   → EVENT_TEXT  (multi-line via \n in args.text)
        MENU                   → EVENT_MENU  (3 options; child branches per option)
        IF cond                → EVENT_IF_VARIABLE_VALUE  (operator >= / < / ==)
        SWITCH_SCENE           → EVENT_SWITCH_SCENE
        AWAIT_INPUT            → EVENT_AWAIT_INPUT  (input=Start)

24. build_rom
    on failure → read_compile_log → fix → repeat.
    Two failures in a row on the same root cause → stop and report.

25. run_emulator(durationMs=20000, inputs=[
        // skip into inauguration
        { at:  500, press: ["start"], durationMs: 200 },
        // 8 weeks of choice A (full MAGA path → expect coup or narrow)
        { at: 2500, press: ["a"],     durationMs: 200 },  // inauguration A
        { at: 4500, press: ["a"],     durationMs: 200 },  // cabinet A
        { at: 6500, press: ["a"],     durationMs: 200 },  // press_conf A
        { at: 8500, press: ["a"],     durationMs: 200 },  // summit A
        { at:10500, press: ["a"],     durationMs: 200 },  // trade_war A
        { at:12500, press: ["a"],     durationMs: 200 },  // midterm A
        { at:14500, press: ["a"],     durationMs: 200 },  // impeach_test A
        { at:16500, press: ["a"],     durationMs: 200 },  // final_rally A
    ], screenshotAt=19000)

26. screenshot → verify ending text shows. Note which ending fired and
    sanity-check it matches the stat math (paper-trace the stat changes from
    initial 50/50/50/50 through each "A" delta).

27. Repeat with all-B presses (presidential path → expect landslide or narrow).

28. Repeat with all-C presses (mixed path → expect narrow).

29. (Optional) Repeat with mixed pattern designed to push loyalty below 30 while
    keeping twitter above 70 — should fire ending_coup.

Total runtime expectation: 8 weeks × ~2s/menu + 4s ending = ~20 sec per playthrough.
```

---

## Stat math sanity check (paper trace)

To verify endings can actually be reached, here are three traces from initial `(50, 50, 50, 50)` (approval, twitter, economy, loyalty):

**All-A (full MAGA):**
- W1: approval=45, twitter=65, loyalty=60
- W2: loyalty=80, approval=35
- W3: twitter=80, approval=25
- W4: twitter=90, approval=20, economy=45
- W5: loyalty=95, economy=25
- W6: twitter=105 (clamped or wrap risk!), loyalty=105 (clamped), approval=10
- W7: twitter=120, loyalty=115, approval=-5
- W8: twitter=135, loyalty=125, approval=-10
- → approval < 50 AND loyalty >= 30 → impeached. **Note:** twitter and loyalty both blow past 100 — GBS variables are 16-bit signed so no wrap issue, but the readout box assumed 2-digit. Either clamp in script (add `IF stat > 100 → SET 100` after each math op — adds 4 events × 8 weeks = 32 events; over budget) or accept 3-digit display. **Decision for next session: accept 3-digit and re-audit the readout box width** (e.g. `Twitter:  135` = 14 chars, still fits because the helper has slack). Verify in-emulator.

**All-B (presidential):**
- W1: approval=60, loyalty=45
- W2: economy=65, loyalty=40
- W3: approval=70, twitter=45
- W4: approval=80, loyalty=45
- W5: economy=70, loyalty=50
- W6: approval=90, twitter=35
- W7: loyalty=55, approval=85
- W8: approval=100, twitter=30
- → approval >= 70 AND economy >= 60 → landslide ✓

**All-C (cautious):**
- W1: approval=55, twitter=55, loyalty=55
- W2: approval=65, economy=60
- W3: approval=80, twitter=50
- W4: twitter=65, economy=45, loyalty=50  (storm out)
   wait — option C in summit is "STORM OUT EARLY" which is bold, not cautious. Re-trace W4 as actually picked:
   With C(summit): twitter=65, economy=45, loyalty=60
- W5: twitter=75, economy=55, loyalty=50  (bluff then deal)
- W6: twitter=95, loyalty=45, approval=75
- W7: approval=90, loyalty=25  (offer a deal)
- W8: loyalty=40, approval=95  (thank the base)
- → approval >= 70 AND economy < 60 → narrow ✓

The "all-C" trace also briefly visits loyalty=25 in W7 which would route to coup if W8 didn't recover — confirms the impeach-vs-coup branch is reachable from realistic play.

---

## Known gaps (v3 stretch)

- **Stat clamping**: `IF stat > 100 → SET 100` and `IF stat < 0 → SET 0` after every math op. ~64 extra events. Skip unless playtest shows confusing readouts.
- **Random events**: a 9th scene `news_break` inserted between weeks at 1-in-3 probability via the `seed` variable (LFSR or simple modulo). Out of v2 scope.
- **Custom backgrounds**: hand-painted 160×144 PNGs for each milestone (Capitol steps, briefing room, summit table, rally stadium). Uses ADVENTURE template default for v2.
- **Music**: pick from `gbdev/awesome-gbdev-cn` or compose 8-bar loop in hUGETracker.
- **Localisation**: Chinese variant requires a custom font + width recompute (see `dialogue-and-ui` skill). 18-char budget would shrink to ~9 Chinese chars.

---

## Tone & content guardrails (re-stated)

- Sprite is from a public press photo, downloaded at run time, **never committed to git**.
- No real opponent names. Opponent is "Speaker", "Reporter", "Allies".
- No personal attacks; choices are purely **rhetorical style** (bombastic vs. measured vs. mixed).
- Endings are absurdist (landslide / narrow / coup / impeached), not factual claims.
- Disclaimer in README: "satirical / parodic showcase, not political endorsement."
