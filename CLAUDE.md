# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CurseForge modpack for Minecraft 1.20.1 (Forge 47.4.0) with a technology progression theme: Create → Mekanism → Ad Astra. The pack is designed for cooperative automation with 141 mods orchestrating a guided path from mechanical engineering to space exploration.

## Core Architecture

**Progression Design Philosophy:**
- **Tier 1 (Create + Tinkers)**: Mechanical contraptions, kinetic energy, early ore doubling
- **Tier 2 (Immersive Engineering + Mekanism entry)**: RF/FE conversion, 3x ore processing
- **Tier 3 (Mekanism deep tech)**: Digital storage (RS/AE2), 5x ore processing, fusion power
- **Tier 4 (Ad Astra)**: Space exploration as endgame sink for accumulated resources

**Dual Storage System Balance:**
- Refined Storage: Mid-game convenience (simple autocrafting)
- Applied Energistics 2: Late-game complexity (advanced patterns, channels)
- KubeJS scripts must gate AE2 recipes behind Mekanism resources
- Polymorph + addons (Polymorphic Energistics, Refined Polymorphism) prevent recipe conflicts

**Magic Mods**: Ars Nouveau and Occultism were intentionally removed to maintain tech focus. If config files for these appear, delete them.

## Development Commands

**Build modpack for distribution:**
```bash
zip -r modpack.zip overrides/ manifest.json modlist.html
```

**Launch local test server:**
```bash
docker compose up -d
docker compose logs -f retn0-minecraft-modpack
```

**Stop and clean server:**
```bash
docker compose down
# For fresh world: rm -rf data/
```

**Update manifest after mod changes:**
Edit `manifest.json` directly - it's the single source of truth. Update `fileID` and `projectID` pairs when upgrading mods. Always regenerate `modlist.html` after manifest changes.

## Key File Structure

- `manifest.json` — CurseForge mod list (141 mods). `CF_EXCLUDE_MODS: 657742` in docker-compose excludes Korean Chat Patch (bundled manually).
- `docker-compose.yaml` — Server runtime (16GB init / 32GB max). Uses `AUTO_CURSEFORGE` to auto-download mods from manifest.
- `overrides/config/` — 347 config files (17 major mod subdirs). Preserve upstream formatting and comments.
- `overrides/mods/` — Only for mods that can't be auto-downloaded (cc-tweaked currently).
- `overrides/kubejs/` — **TO BE CREATED**. Recipe tweaks, progression gates, storage system balancing.
- `overrides/ftbquests/` — **TO BE CREATED**. Quest tree implementing 4-tier progression concept.
- `data/` — Git-ignored Docker runtime (worlds, logs, libraries). Delete to reset server state.

## Modpack Development Workflow

**Adding/Updating Mods:**
1. Update `manifest.json` with new projectID/fileID pairs
2. If mod has configs, test in Docker and commit finalized configs to `overrides/config/`
3. Regenerate modlist.html
4. Test clean startup: `docker compose up -d` and watch logs

**KubeJS Scripting (when implemented):**
- Place scripts in `overrides/kubejs/server_scripts/` for recipe modifications
- Use `overrides/kubejs/startup_scripts/` for custom blocks/items if needed
- File naming: `{feature}-{mod}.js` (e.g., `progression-ae2.js`, `balance-mekanism-tools.js`)
- Reference mods by canonical IDs: `create`, `mekanism`, `refinedstorage`, `ae2`

**FTB Quests Design (when implemented):**
1. Draft quest flow in FTB Quests UI (in-game editor)
2. Align required recipes via KubeJS so milestones unlock naturally
3. Use exploration content (Twilight Forest, Cataclysm, YUNG's structures) as optional reward branches, not hard gates
4. Export quest data lands in `overrides/ftbquests/` - commit entire directory

**Config File Standards:**
- JSON/JSON5: 2-space indentation
- TOML/CFG: 4-space indentation
- Keep upstream comments and key ordering when possible

## Testing Requirements

**Before committing config changes:**
1. Launch via `docker compose up -d` - confirm no startup errors
2. Join with client - verify JEI shows recipes, FTB Quests loads, world generates correctly
3. Check server console for TPS drops or mod warnings

**When modifying automation/progression:**
- Test in disposable world (use creative mode + /ftbquests to validate gates)
- Ensure recipes remain achievable without exploits
- Monitor JEI for recipe spam (sign of conflicts)

## Docker Environment Details

The itzg/minecraft-server container uses:
- `CF_API_KEY` from `.env` (required for CurseForge downloads)
- `CF_MODPACK_ZIP: /modpack.zip` mounted from root (build with `run.sh` before first launch)
- Auto-installs Forge 47.4.0 and all mods from manifest
- Runs on port 25565 with `DIFFICULTY: hard`
- TZ set to `Asia/Seoul`

**Never commit:**
- `.env` file (has CF_API_KEY)
- `data/` directory contents
- Server operator credentials or world backups

## Critical Mods Reference

If these are missing from manifest, the progression concept breaks:
- **328085** (Create), **268560** (Mekanism), **231951** (Immersive Engineering), **74072** (Tinkers Construct)
- **243076** (Refined Storage), **223794** (Applied Energistics 2), **388800** (Polymorph)
- **635042** (Ad Astra), **945470** (Mekanism: Ad Astra Ores)
- **289412** (FTB Quests), **238086** (KubeJS)

Polymorph addons (941096, 943086) must remain installed to prevent RS/AE2 recipe conflicts with 141 mods.
