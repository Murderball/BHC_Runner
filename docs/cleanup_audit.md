# Cleanup Audit (Legacy Purge, Baseline-Safe)

## Phase A — Inventory + Reachability
### A1) Runtime Entry Points
- Startup room order begins at `rm_startup` and includes menu/loading/gameplay rooms through RoomOrderNodes in project manifest.
- Core runtime controller: `obj_game` Create/Step events (global init, input init, chunk system init, level prep, chart load, BG manager spawn, startup loading gate).
- Boot/init scripts reached from `obj_game` include: `scr_globals_init`, `scr_input_init`, `scr_chunk_system_init`, `scr_level_prepare_for_room` fallback `scr_level_master_sections_init`, `scr_chunk_build_section_sequences`, `scr_chart_load`, `scr_apply_difficulty`, `scr_phrases_load`, `scr_bg_prewarm_textures`, `scr_tileset_prewarm_textures`.
- Baseline room family preserved: Level 3 normal flow rooms (`rm_level03` and Level 3 chunk rooms), boss room flow, chart/hitline/note/UI and BG systems.

### A2) Dependency Graph Method
- Manifest graph source: `BHC Runner.yyp` resources and room order.
- Code graph source: all `objects/**/*.gml` and `scripts/**/*.gml` references (direct calls + `script_execute` + `asset_get_index`/`room_get_name` checks).
- Safety treatment: string-based lookups and debug-gated paths treated as USED unless fully outside the `.yyp` manifest.

### A3) Used / Unused / Uncertain
#### Confirmed USED (kept)
- All resources present in `BHC Runner.yyp` were kept in-place.
- Critical baseline systems kept untouched: chunk pipeline, chart-time/hitline/note flow, difficulty system, bg manager/shaders, gameplay UI, debug hooks.

#### Confirmed UNUSED (quarantined to `/_legacy`)
- scripts: 45 directories moved (not referenced by `BHC Runner.yyp`).
- rooms: 4 directories moved (not referenced by `BHC Runner.yyp`).
- sprites: 58 directories moved (not referenced by `BHC Runner.yyp`).
- sounds: 16 directories moved (not referenced by `BHC Runner.yyp`).
- shaders: 1 directories moved (not referenced by `BHC Runner.yyp`).
- tilesets: 7 directories moved (not referenced by `BHC Runner.yyp`).

<details><summary>scripts moved list</summary>

```text
scr_attack_perform
scr_bg_set_by_difficulty
scr_bg_sprite_for_ci
scr_bg_sprite_for_slot_diff
scr_bg_warmup
scr_bg_warmup_fast
scr_chart_now_time
scr_chunk_cache_preload_step
scr_chunk_clear_ci
scr_chunk_clear_room
scr_chunk_files_init
scr_chunk_stamp_ci
scr_chunk_stamp_room
scr_chunk_stamp_step
scr_chunk_stamp_to_maps_step
scr_datafile_read_all_text
scr_editor_delete_enemy_at_cursor
scr_editor_place_enemy
scr_enemy_budget_init
scr_enemy_damage_active
scr_enemy_damage_lane
scr_enemy_window_times
scr_find_hittable_note_in_lane
scr_fmod_event_play
scr_fmod_event_stop
scr_get_level_start_time
scr_lane_pressed
scr_layer_first_sprite_name
scr_music_bar_math
scr_music_pause_start
scr_music_pause_stop
scr_player_jump
scr_player_lane_from_y
scr_restamp_visuals_for_loaded_slots
scr_room_flow_init
scr_room_fps
scr_section_index_from_ci
scr_set_difficulty_band
scr_story_events_refresh
scr_tiledata_shift_index
scr_time_camera_left
scr_time_hitline
scr_time_to_beat
scr_try_hit_jump_note
scr_visual_bands_init
```
</details>

<details><summary>rooms moved list</summary>

```text
rm_chunk_break_1_00
rm_level02
rm_level04
rm_level06
```
</details>

<details><summary>sprites moved list</summary>

```text
Level_3_tl_visual
bss_animal_1
bss_bubblegum_1
bss_bubblegum_2
bss_cthulu_1
bss_cthulu_2
bss_cyberpunk_1
bss_cyberpunk_2
bss_powaranger_1
bss_powaranger_2
bss_primal_1
bss_primal_2
gtr_bubblegum_1
gtr_bubblegum_2
gtr_cthulu_1
gtr_cthulu_2
gtr_cyperpunk_1
gtr_cyperpunk_2
gtr_powaranger_1
gtr_powaranger_2
gtr_primal_1
gtr_primal_2
spr_bg_level5_easy_00
spr_bg_level5_easy_01
spr_bg_level5_easy_02
spr_bg_level5_easy_03
spr_bg_level5_easy_04
spr_bg_level5_easy_05
spr_bg_level5_easy_06
spr_bg_level5_easy_07
spr_bg_level5_hard_00
spr_bg_level5_hard_01
spr_bg_level5_hard_02
spr_bg_level5_hard_03
spr_bg_level5_hard_04
spr_bg_level5_hard_05
spr_bg_level5_hard_06
spr_bg_level5_hard_07
spr_bg_level5_normal_00
spr_bg_level5_normal_01
spr_bg_level5_normal_02
spr_bg_level5_normal_03
spr_bg_level5_normal_04
spr_bg_level5_normal_05
spr_bg_level5_normal_06
spr_bg_level5_normal_07
spr_guitarist_skate
spr_horns
spr_pop_tart
spr_scene_kid
spr_skin_guitarist_cyberpunk
spr_ts_boss3
spr_ts_easy1
spr_ts_easy5
spr_ts_hard1
spr_ts_hard5
spr_ts_normal1
spr_ts_normal5
```
</details>

<details><summary>sounds moved list</summary>

```text
snd_boss_music_level2
snd_boss_music_level4
snd_boss_music_level5
snd_boss_music_level6
snd_song_2_easy
snd_song_2_hard
snd_song_2_normal
snd_song_4_easy
snd_song_4_hard
snd_song_4_normal
snd_song_5_easy
snd_song_5_hard
snd_song_5_normal
snd_song_6_easy
snd_song_6_hard
snd_song_6_normal
```
</details>

<details><summary>shaders moved list</summary>

```text
shd_saturation
```
</details>

<details><summary>tilesets moved list</summary>

```text
TileSet_Easy5
TileSet_Hard5
TileSet_Normal5
Tileset_Easy1
Tileset_Hard1
Tileset_Normal1
ts_level3_master
```
</details>

#### UNCERTAIN / STRING-REF (kept)
- Dynamic/script-execute usages (e.g., `script_execute(scr_player_snap_to_spawn)`) were preserved.
- String asset lookups used by runtime/UI/pause/menu flows (e.g., `asset_get_index("menu_resume")`, `asset_get_index(room_name)`) were preserved.
- Global-flag/debug/editor conditionals using `variable_global_exists(...)` were preserved.

## Phase B — Cleanup Plan (safe-first)
- **Delete:** none directly from canonical project manifest resources.
- **Quarantine:** all filesystem resource directories not in `.yyp` moved into `/_legacy` for reversible cleanup.
- **Consolidate:** not applied (to avoid behavior risk).

### Rollback Plan
- Restore all quarantined content: `git restore --source=HEAD --staged --worktree .` (full rollback) or selectively restore paths from `/_legacy` moves.
- Revert only cleanup commit: `git revert <cleanup_commit_sha>`.

## Phase C — Implementation
- Created quarantine tree: `/_legacy/scripts`, `/_legacy/objects`, `/_legacy/rooms`, `/_legacy/assets_notes`, plus `/_legacy/assets/{sprites,sounds,shaders,tilesets}`.
- Moved only resources proven outside project manifest scope (`BHC Runner.yyp` non-members).
- No runtime references were modified; baseline systems remain intact.

## Phase D — Verification
### D1) Verification Checklist
- [ ] Boot to menu
- [ ] Start baseline level (World Level 3 Normal Stage 1)
- [ ] Hitline + note grid render
- [ ] Chart loads for baseline difficulty
- [ ] Background/parallax/shader BPM sync intact
- [ ] Chunk streaming works for baseline flow
- [ ] No missing-asset logs for baseline resources

### D2) What Changed
- Quarantined total directories: 131.
- Category counts: scripts=45, rooms=4, sprites=58, sounds=16, shaders=1, tilesets=7.
- Top-level folders touched: `_legacy/`, `scripts/`, `rooms/`, `sprites/`, `sounds/`, `shaders/`, `tilesets/`, `docs/`.

## Hard Delete Results

### Method and Gate Evidence
- Iterated each quarantined item under `/_legacy` and ran exact-name repository searches excluding `/_legacy` (`rg -n -F "<asset_name>" --glob '!_legacy/**'`).
- For each `.yy` inside candidate folders, extracted UUID-like IDs and searched them globally (same exclusion) to catch non-name references.
- Applied dynamic/string safety by treating any out-of-legacy name hit as **UNCERTAIN** (kept), including script names appearing in comments/resource-order metadata and UUID hits.
- Room/object reachability: no `_legacy` room/object names were referenced by active routing or creation paths outside docs.

### Deleted (proven unused)
- **Scripts deleted (38):**
  `scr_attack_perform`, `scr_bg_sprite_for_ci`, `scr_chart_now_time`, `scr_chunk_cache_preload_step`, `scr_chunk_clear_ci`, `scr_chunk_clear_room`, `scr_chunk_stamp_ci`, `scr_chunk_stamp_room`, `scr_chunk_stamp_step`, `scr_chunk_stamp_to_maps_step`, `scr_datafile_read_all_text`, `scr_editor_delete_enemy_at_cursor`, `scr_editor_place_enemy`, `scr_enemy_budget_init`, `scr_enemy_damage_active`, `scr_enemy_window_times`, `scr_find_hittable_note_in_lane`, `scr_fmod_event_play`, `scr_fmod_event_stop`, `scr_get_level_start_time`, `scr_lane_pressed`, `scr_layer_first_sprite_name`, `scr_music_bar_math`, `scr_music_pause_start`, `scr_music_pause_stop`, `scr_player_jump`, `scr_player_lane_from_y`, `scr_restamp_visuals_for_loaded_slots`, `scr_room_flow_init`, `scr_section_index_from_ci`, `scr_set_difficulty_band`, `scr_story_events_refresh`, `scr_tiledata_shift_index`, `scr_time_camera_left`, `scr_time_hitline`, `scr_time_to_beat`, `scr_try_hit_jump_note`, `scr_visual_bands_init`.
- **Objects deleted:** none (no quarantined legacy objects present).
- **Rooms deleted (4):** `rm_chunk_break_1_00`, `rm_level02`, `rm_level04`, `rm_level06`.
- **Assets deleted (80):**
  - Sprites deleted (56): all quarantined sprites except `spr_ts_boss3` and `spr_ts_hard1`.
  - Sounds deleted (16): all quarantined sounds.
  - Shaders deleted (1): `shd_saturation`.
  - Tilesets deleted (7): all quarantined tilesets.

### Kept (UNCERTAIN) and reasons
- **Scripts kept (7):**
  - `scr_bg_set_by_difficulty`, `scr_bg_sprite_for_slot_diff`, `scr_bg_warmup`, `scr_bg_warmup_fast`, `scr_enemy_damage_lane`: name hits found in active script trees (`scripts/scr_attack_notes_in_window/...`).
  - `scr_chunk_files_init`: name appears in active code comments as dependency context.
  - `scr_room_fps`: appears in active `scripts/BHC Runner.resource_order` metadata.
- **Sprites kept (2):**
  - `spr_ts_boss3`, `spr_ts_hard1`: UUID hits found outside `_legacy`; retained to avoid unsafe deletion.

### Batch Execution + Build/Compile Checks
- Batch 1 (scripts): deleted proven-unused script folders, then verified no active-manifest references for sampled deleted scripts.
- Batch 2 (objects): no-op (no legacy objects existed).
- Batch 3 (rooms): deleted all proven-unused legacy rooms; only docs references remain outside `_legacy`.
- Batch 4 (remaining assets): deleted proven-unused sprites/sounds/shaders/tilesets; only docs references remain outside `_legacy` for sampled names.
- **Compile gate note:** this environment has no GameMaker build CLI (`Igor`/`gmassetcompiler`) installed, so full compile execution is not available here. Static reference gates were applied conservatively; uncertain items were retained.
