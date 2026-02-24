/// obj_chunk_manager : Create

// 0) Init micro-profiler
if (script_exists(scr_microprof_init)) scr_microprof_init();

boss_transition_fired = false;

// 1) Init chunk constants FIRST
scr_chunk_system_init();

// 2) Init sections (t0/t1) generically
scr_level_master_sections_init();

// 3) Build per-section sequences
scr_chunk_build_section_sequences();

// 4) Create / fetch tilemaps & layer ids
scr_chunk_maps_init();

// Ensure difficulty globals exist
if (!variable_global_exists("DIFFICULTY")) global.DIFFICULTY = "normal";
if (!variable_global_exists("difficulty")) global.difficulty = string_lower(string(global.DIFFICULTY));

// Apply difficulty properly (sets bg_diff_i + forces BG repaint); don't swap audio here
scr_apply_difficulty(global.difficulty, "room_start", true, false);


// Chunk cache MUST exist before any stamping/loading
if (!variable_instance_exists(id, "chunk_cache") || !ds_exists(chunk_cache, ds_type_map)) {
    chunk_cache = ds_map_create();
}

// ----------------------------------------------------
// Cache + state
// ----------------------------------------------------
chunk_sections = global.master_sections;

// Build section_t0_map
section_t0_map = ds_map_create();
for (var _si = 0; _si < array_length(chunk_sections); _si++) {
    var _s = chunk_sections[_si];
    ds_map_add(section_t0_map, _s.name, _s.t0);
}

buffer_chunks    = global.BUFFER_CHUNKS;
spawn_ahead      = global.SPAWN_AHEAD;
despawn_behind   = global.DESPAWN_BEHIND;

// --- Chunk Background System: painted BG per slot ---
global.bg_slot_near = array_create(buffer_chunks, -1);
global.bg_slot_far  = array_create(buffer_chunks, -1);

// IMPORTANT: reset duplicate-guard so the new run can repaint cleanly
global.bg_slot_last_ci = array_create(buffer_chunks, -999999);

// Force a full repaint once slots/ci exist
global.bg_repaint_all = true;

slot_origin_ci   = 0;

hot_reload_chunks = true; // dev flag

// Track what absolute chunk index is in each slot
slot_ci          = array_create(buffer_chunks, -1);
slot_label       = array_create(buffer_chunks, "");
slot_room_name   = array_create(buffer_chunks, "");

// Chunk files map (key -> filename)
if (variable_instance_exists(id, "chunk_files") && ds_exists(chunk_files, ds_type_map)) {
    ds_map_destroy(chunk_files);
}

chunk_files = ds_map_create();

/// Count rooms per stem: rm_chunk_<stem>_00, 01, ...
function _count_avail_rooms(_stem)
{
    var room_prefix = "rm_chunk_";
    if (variable_global_exists("CHUNK_ROOM_PREFIX") && is_string(global.CHUNK_ROOM_PREFIX)) {
        room_prefix = global.CHUNK_ROOM_PREFIX;
    }

    var count = 0;
    for (var i = 0; i < 200; i++)
    {
        var kk = (i < 10) ? ("0" + string(i)) : string(i);
        var room_name = room_prefix + _stem + "_" + kk;

        if (asset_get_index(room_name) != -1)
            count++;
        else
            break;
    }
    return max(1, count);
}


// Build chunk_files dynamically so this object is UNIVERSAL again
for (var si = 0; si < array_length(chunk_sections); si++)
{
    var s = chunk_sections[si];
    var stem = scr_sec_to_stem(s.name);
    var avail = _count_avail_rooms(stem);

    for (var i2 = 0; i2 < avail; i2++)
    {
        var kk2 = (i2 < 10) ? ("0" + string(i2)) : string(i2);
        var key = stem + "_" + kk2;
		var file_prefix = "chunk_rm_chunk_";
		if (variable_global_exists("CHUNK_FILE_PREFIX") && is_string(global.CHUNK_FILE_PREFIX)) {
		    file_prefix = global.CHUNK_FILE_PREFIX;
		}
		var fname = file_prefix + stem + "_" + kk2 + ".json";

        ds_map_add(chunk_files, key, fname);
    }
}
// ====================================================
// PRIME FIRST CHUNK SYNCHRONOUSLY (prevents spawn fall-through)
// ====================================================
global.level_stream_ready = false;

// Local helper: section name at time t (same logic as Step)
function __sec_name_at_time(t) {
    var arr = chunk_sections;
    if (t < arr[0].t0) return arr[0].name;

    for (var ii = 0; ii < array_length(arr); ii++) {
        var s = arr[ii];
        if (t >= s.t0 && t < s.t1) return s.name;
    }
    return arr[array_length(arr) - 1].name;
}

function __prime_first_chunk()
{
    // Must have maps
    if (!variable_global_exists("tm_collide") || global.tm_collide == -1) return false;

    // Time->chunk lattice constants (match Step)
    var pps = (variable_global_exists("WORLD_PPS") && is_real(global.WORLD_PPS) && !is_nan(global.WORLD_PPS))
        ? global.WORLD_PPS : 1.0;
    if (pps <= 0) pps = 1.0;

    var chunk_w_px = global.CHUNK_W_TILES * global.TILE_W;
    if (chunk_w_px <= 0) chunk_w_px = 1;

    // First chunk index (ci=0), but section lookup uses TILE_SECTION_SHIFT_S
    var tile_shift = (variable_global_exists("TILE_SECTION_SHIFT_S") ? global.TILE_SECTION_SHIFT_S : 0.0);
    var t_at = tile_shift + 0.0001;

    var sec = __sec_name_at_time(t_at);

    if (!ds_exists(global.chunk_seq, ds_type_map)) return false;
    if (!ds_map_exists(global.chunk_seq, sec)) return false;

    var seq = global.chunk_seq[? sec];
    if (is_undefined(seq) || array_length(seq) <= 0) return false;

    var s0 = 0;
    if (ds_map_exists(section_t0_map, sec)) s0 = section_t0_map[? sec];

    var t_into = t_at - s0;

    var idx;
    if (variable_global_exists("chunk_seconds") && is_real(global.chunk_seconds) && global.chunk_seconds > 0) {
        var _chunk_sec_denom = global.chunk_seconds;
        if (_chunk_sec_denom == 0) {
            show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
            _chunk_sec_denom = 1;
        }
        idx = floor(t_into / _chunk_sec_denom);
    } else {
        var _pps_denom = pps;
        if (_pps_denom == 0) {
            show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
            _pps_denom = 1;
        }
        idx = floor(t_into / (chunk_w_px / _pps_denom));
    }
    idx = clamp(idx, 0, array_length(seq) - 1);

    var key = seq[idx];

    if (!ds_map_exists(chunk_files, key)) return false;
    var fname = chunk_files[? key];

    // Load immediately (no queue delay)
    var data = undefined;
    if (ds_map_exists(chunk_cache, fname)) {
        data = chunk_cache[? fname];
    } else {
        data = scr_chunk_load(fname);
        if (!is_undefined(data)) ds_map_add(chunk_cache, fname, data);
    }

    if (is_undefined(data)) return false;

    // Stamp immediately into slot 0 so collision exists BEFORE player snap
    scr_chunk_stamp_to_maps(data, 0);

    // Mark slot 0 as already assigned so Step doesn’t re-queue stamp instantly
    if (is_array(slot_ci) && array_length(slot_ci) > 0) slot_ci[0] = 0;

    // Paint BG for slot 0 as well
    if (script_exists(scr_bg_paint_slot)) scr_bg_paint_slot(0, 0);

    return true;
}

if (__prime_first_chunk())
{
    global.level_stream_ready = true;

    // Now that ground exists, snap player properly (safe)
    if (script_exists(scr_player_snap_to_spawn)) script_execute(scr_player_snap_to_spawn);
}
else
{
    // If prime fails (missing file etc.), we stay gated; player won't drop under floor anymore.
    global.level_stream_ready = false;
}
