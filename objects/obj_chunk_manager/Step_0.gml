/// obj_chunk_manager : Step
if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED) exit;

if (script_exists(scr_microprof_frame_begin)) scr_microprof_frame_begin();

// --------------------------------------------------
// Boss transition by per-level/per-difficulty end time
// --------------------------------------------------
if (room == rm_menu || (variable_global_exists("in_menu") && global.in_menu)) { /* skip */ }
else if (room == rm_loading || (variable_global_exists("in_loading") && global.in_loading)) { /* skip */ }
else
{
    // Pause detection (defensive)
    var paused = false;
    if (variable_global_exists("paused")) paused = global.paused;
    else if (variable_global_exists("is_paused")) paused = global.is_paused;
    else if (variable_global_exists("IN_PAUSE_MENU")) paused = global.IN_PAUSE_MENU;

    if (!paused && !boss_transition_fired)
    {
        var end_s = scr_level_end_time_s(); // uses room_get_name(room) key
        if (end_s > 0)
        {
            var now_s = scr_chart_time();
            if (now_s >= end_s)
            {
                var boss_rm = scr_level_boss_room(room_get_name(room));
                if (boss_rm != -1)
                {
                    boss_transition_fired = true;
                    room_goto(boss_rm);
                }
            }
        }
    }
}

// --------------------------------------------------
// TIME SOURCE (editor uses chart-time, gameplay uses song-time)
// --------------------------------------------------
var ed_on = (variable_global_exists("editor_on") && global.editor_on);

var t_now = ed_on ? scr_chart_time() : scr_song_time();
if (!is_real(t_now) || is_nan(t_now)) t_now = 0.0;
if (t_now < 0) t_now = 0.0;

// --------------------------------------------------
// Difficulty watch (unchanged)
// --------------------------------------------------
if (!variable_global_exists("difficulty")) global.difficulty = "normal";
if (!variable_global_exists("difficulty_prev")) global.difficulty_prev = "";

if (!variable_instance_exists(id, "prev_ed_on")) prev_ed_on = false;

if (variable_global_exists("bg_repaint_all") && global.bg_repaint_all) {
    global.dbg_last_bg_repaint_t = (script_exists(scr_song_time) ? scr_song_time() : -1);
    var __mp_repaint = (script_exists(scr_microprof_begin) ? scr_microprof_begin("bg.repaint_all") : 0);
    scr_bg_repaint_all_slots();
    if (script_exists(scr_microprof_end)) scr_microprof_end("bg.repaint_all", __mp_repaint);
    global.bg_repaint_all = false;
}

if (!prev_ed_on && ed_on) {
    scr_editor_enter_reset();
}
prev_ed_on = ed_on;

if (global.difficulty != global.difficulty_prev) {
    show_debug_message("[DIFF] " + string(global.difficulty_prev) + " -> " + string(global.difficulty) + "  t=" + string(t_now));
    scr_set_difficulty_visuals(global.difficulty);
    global.difficulty_prev = global.difficulty;
}

// --------------------------------------------------
// SAFETY: ensure Create ran / maps exist
// --------------------------------------------------
if (!variable_instance_exists(id, "chunk_cache") || is_undefined(chunk_cache)) {
    chunk_cache = ds_map_create();
    show_debug_message("[obj_chunk_manager] chunk_cache missing; created in Step.");
}
if (!variable_instance_exists(id, "chunk_files") || is_undefined(chunk_files)) {
    chunk_files = ds_map_create();
    show_debug_message("[obj_chunk_manager] chunk_files missing; created in Step.");
}
if (!variable_instance_exists(id, "section_t0_map") || is_undefined(section_t0_map) || !ds_exists(section_t0_map, ds_type_map)) {
    section_t0_map = ds_map_create();
    for (var _smi = 0; _smi < array_length(chunk_sections); _smi++) {
        var _sm = chunk_sections[_smi];
        ds_map_add(section_t0_map, _sm.name, _sm.t0);
    }
}

if (variable_global_exists("force_chunk_refresh") && global.force_chunk_refresh) {
    global.force_chunk_refresh = false;
    global.dbg_last_chunk_refresh_t = (script_exists(scr_song_time) ? scr_song_time() : -1);

    if (variable_instance_exists(id, "chunk_cache") && !is_undefined(chunk_cache)) ds_map_clear(chunk_cache);

    // Force every slot to be "dirty" so it restamps
    if (is_array(slot_ci)) {
        for (var ii = 0; ii < array_length(slot_ci); ii++) slot_ci[ii] = -1;
    }
}

// --------------------------------------------------
// Tilemaps must be valid
// --------------------------------------------------
if (!variable_global_exists("tm_collide") || global.tm_collide == -1) {
    if (script_exists(scr_microprof_frame_end)) scr_microprof_frame_end();
    exit;
}

var have_any_vis =
    (variable_global_exists("tm_vis_easy")   && global.tm_vis_easy   != -1) ||
    (variable_global_exists("tm_vis_normal") && global.tm_vis_normal != -1) ||
    (variable_global_exists("tm_vis_hard")   && global.tm_vis_hard   != -1);

if (!have_any_vis) {
    if (script_exists(scr_microprof_frame_end)) scr_microprof_frame_end();
    exit;
}

// --------------------------------------------------
// Process queues (prevents hitches)
// --------------------------------------------------
var __mp_stampq = (script_exists(scr_microprof_begin) ? scr_microprof_begin("chunk.stamp_queue_step") : 0);
if (script_exists(scr_chunk_stamp_queue_step)) scr_chunk_stamp_queue_step();
if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.stamp_queue_step", __mp_stampq);

var __mp_loadq = (script_exists(scr_microprof_begin) ? scr_microprof_begin("chunk.load_queue_step") : 0);
if (script_exists(scr_chunk_load_queue_step))  scr_chunk_load_queue_step(chunk_cache);
if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.load_queue_step", __mp_loadq);

// Debug defaults (prevents Draw crashes)
dbg_key = ""; dbg_fname = ""; dbg_sec = "";

// ----------------------------------------------------
// Offsets
// ----------------------------------------------------
if (!variable_global_exists("CHUNK_X_OFFSET_PX"))   global.CHUNK_X_OFFSET_PX = 0;
if (!variable_global_exists("CHUNK_TIME_OFFSET_S")) global.CHUNK_TIME_OFFSET_S = 0.0;

var xoff      = global.CHUNK_X_OFFSET_PX;       // VISUAL ONLY
var chunk_off = global.CHUNK_TIME_OFFSET_S;     // INDEXING / SECTION ALIGNMENT

xoff = global.CHUNK_X_OFFSET_PX;

// Apply fine pixel offset ONLY
layer_x(global.layer_vis_easy_id,   -xoff);
layer_x(global.layer_vis_normal_id, -xoff);
layer_x(global.layer_vis_hard_id,   -xoff);
layer_x(global.layer_collide_id,    -xoff);

// ----------------------------------------------------
// Helper: section name at time t
// ----------------------------------------------------
function sec_name_at_time(t) {
    var arr = chunk_sections;
    if (t < arr[0].t0) return arr[0].name;

    for (var ii = 0; ii < array_length(arr); ii++) {
        var s = arr[ii];
        if (t >= s.t0 && t < s.t1) return s.name;
    }
    return arr[array_length(arr) - 1].name;
}

// ----------------------------------------------------
// Constants
// ----------------------------------------------------
var pps = (variable_global_exists("WORLD_PPS") && is_real(global.WORLD_PPS) && !is_nan(global.WORLD_PPS))
    ? global.WORLD_PPS : 1.0;
if (pps <= 0) pps = 1.0;

var chunk_w_px = global.CHUNK_W_TILES * global.TILE_W;
if (chunk_w_px <= 0) chunk_w_px = 1;

// ----------------------------------------------------
// IMPORTANT:
// - CI indexing is PURE song time (no xoff, no chunk_off)
// - Section lookup may use CHUNK_TIME_OFFSET_S
// ----------------------------------------------------

// --- CI INDEXING (pure, stable, grid-locked) ---
var denom_chunk_w = chunk_w_px;
if (denom_chunk_w == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_chunk_w = 1;
}
cur_ci = floor((t_now * pps) / denom_chunk_w);
if (cur_ci < 0) cur_ci = 0;

// Ring buffer base
var denom_buffer_chunks = buffer_chunks;
if (denom_buffer_chunks == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_buffer_chunks = 1;
}
base_ci = floor(cur_ci / denom_buffer_chunks) * buffer_chunks;
if (base_ci < 0) base_ci = 0;

var __mp_slots = (script_exists(scr_microprof_begin) ? scr_microprof_begin("chunk.slot_assign") : 0);

// ----------------------------------------------------
// Fill EVERY slot in the strip
// ----------------------------------------------------
for (var slot = 0; slot < buffer_chunks; slot++)
{
    var ci = base_ci + slot;

    // already correct?
    if (slot_ci[slot] == ci) continue;

    var tile_shift = (variable_global_exists("TILE_SECTION_SHIFT_S") ? global.TILE_SECTION_SHIFT_S : 0.0);

    // Section lookup time used for TILE selection (not chunk lattice)
    var denom_pps = pps;
    if (denom_pps == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_pps = 1;
    }
    var t_at = (ci * chunk_w_px) / denom_pps + tile_shift + 0.0001;
    var sec = sec_name_at_time(t_at);

    // Sequence exists?
    if (!ds_map_exists(global.chunk_seq, sec)) {
        slot_label[slot] = "SEQ MISSING FOR SECTION: [" + sec + "]";
        continue;
    }

    var seq = global.chunk_seq[? sec];
    if (is_undefined(seq) || array_length(seq) <= 0) {
        slot_label[slot] = sec + " :: (EMPTY SEQ)";
        continue;
    }

    // Find section start time (t0) from cache map
    var s0 = 0;
    if (ds_map_exists(section_t0_map, sec)) s0 = section_t0_map[? sec];

    // Index within section
    var t_into = t_at - s0;

    var idx;
    if (variable_global_exists("chunk_seconds") && is_real(global.chunk_seconds) && global.chunk_seconds > 0) {
        var denom_chunk_seconds = global.chunk_seconds;
        if (denom_chunk_seconds == 0)
        {
            show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
            denom_chunk_seconds = 1;
        }
        idx = floor(t_into / denom_chunk_seconds);
    } else {
        var denom_pps_inner = pps;
        if (denom_pps_inner == 0)
        {
            show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
            denom_pps_inner = 1;
        }
        var denom_chunk_time = (chunk_w_px / denom_pps_inner);
        if (denom_chunk_time == 0)
        {
            show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
            denom_chunk_time = 1;
        }
        idx = floor(t_into / denom_chunk_time);
    }

    idx = clamp(idx, 0, array_length(seq) - 1);

    var key = seq[idx];

    // key -> filename (guard!)
    if (!ds_map_exists(chunk_files, key)) {
        slot_label[slot] = sec + " :: MISSING MAP KEY " + string(key);
        continue;
    }

    var fname = chunk_files[? key];

    // Cache or queue load
    var data = undefined;

    if (ds_map_exists(chunk_cache, fname)) {
        data = chunk_cache[? fname];
    } else {
        if (script_exists(scr_chunk_load_queue_request)) scr_chunk_load_queue_request(fname);
        slot_label[slot] = sec + " :: LOADING " + string(key);
        continue;
    }

    if (is_undefined(data)) {
        slot_label[slot] = sec + " :: DATA UNDEF " + string(key);
        continue;
    }

    // Mark slot as assigned immediately (prevents duplicate queueing)
    slot_ci[slot] = ci;
    slot_label[slot] = sec + " :: " + string(key);

    // Enqueue incremental stamping job
    if (!variable_global_exists("chunk_stamp_queue") || !is_array(global.chunk_stamp_queue)) {
        global.chunk_stamp_queue = [];
        global.chunk_stamp_queue_head = 0;
    }

    var job = {
        chunk_data: data,
        slot: slot,
        ci: ci,
        row: 0,
        rows_per_step: (variable_global_exists("chunk_stamp_rows_per_job") ? global.chunk_stamp_rows_per_job : 8)
    };
    array_push(global.chunk_stamp_queue, job);

    // BG paint ONCE per assignment (by global chunk index)
    scr_bg_paint_slot(slot, ci);

    // (optional debug)
    slot_room_name[slot] = "rm_chunk_" + string(key);

    // Update last-good debug
    dbg_sec   = sec;
    dbg_key   = string(key);
    dbg_fname = fname;
}

if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.slot_assign", __mp_slots);
if (script_exists(scr_microprof_frame_end)) scr_microprof_frame_end();
