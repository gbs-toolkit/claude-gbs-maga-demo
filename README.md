# claude-gbs-maga-demo

A short **text-adventure** for the [`gbs`](https://github.com/gbs-toolkit/claude-gbs-plugin) plugin, starring a Trump-styled protagonist navigating a satirical political campaign.

> **Status: skeleton.** Resources fill in via Claude Code + plugin MCP tools after the GB Studio GUI initialises the project.
>
> **Tone disclaimer.** The demo is a satirical / parodic showcase, not political endorsement. It exists to stress-test the plugin's text-branching and `convert_image_to_sprite` (real photo → DMG sprite) pipeline.

## What this demo aims at

- **`convert_image_to_sprite` pipeline** — a real photo of a public figure → 4-shade DMG sprite
- **Long branching dialogue** — choices update flag variables; ending depends on flag accumulation
- **Multiple endings** — driven by 16-bit signed flag variables
- **Per-line text width** — exercises the dialogue width budget (~18 chars/line in English)

See [`DESIGN.md`](DESIGN.md) for branching tree and ending conditions.

## Setup

1. Install plugin:
   ```
   /plugin marketplace add https://github.com/gbs-toolkit/claude-gbs-marketplace
   /plugin install gbs@gbs-toolkit
   ```
2. **Initialise the GB Studio project** (one-time, GUI):
   - Open GB Studio → **New Project**.
   - **Project name**: `maga`. **Folder**: this repo's `gbsproj/`. **Template**: `Blank` (or `Sample Project` if Blank isn't offered — Claude clears the template's default scene in step 11 of the build sequence).
   - Click **Create Project**, then close GB Studio. No GUI editing needed; the rest happens through MCP tools.
   - **Note**: "Adventure" in this demo is a *scene type*, not a project template. Claude sets it per-scene via `create_scene(..., type="ADVENTURE")`.
3. **Download the source photo** (kept out of git for licensing reasons):
   ```bash
   ./scripts/download_assets.sh
   ```
   This places `assets/source/trump.jpg` for `convert_image_to_sprite` to consume.
4. Configure `.mcp.json`:
   ```bash
   cp .mcp.json.example .mcp.json
   $EDITOR .mcp.json
   ```
5. Launch Claude Code in this directory:
   > "Read DESIGN.md and start building the MAGA demo."

## License

MIT. Source photo URL is third-party press photography, downloaded at runtime — **not redistributed** by this repo.
