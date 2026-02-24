/// scr_chunk_build_section_sequences()
/// Builds per-section ordered chunk keys.
/// WRAPS (repeats) if a section needs more chunks than exist as room assets.
/// Does NOT rely on global.chunk_files or scr_chunk_files_init.

function scr_chunk_build_section_sequences()
{
    // Ensure required globals exist (prevents init-order crashes)
    if (!variable_global_exists("WORLD_PPS")) scr_globals_init();
    if (!variable_global_exists("CHUNK_W_TILES")) scr_chunk_system_init();

    // NEW: generic sections init
    scr_level_master_sections_init();
    if (!variable_global_exists("master_sections") || !is_array(global.master_sections)) return;

    var pps = global.WORLD_PPS;
    if (pps <= 0) pps = 1;

    var chunk_w_px = global.CHUNK_W_TILES * global.TILE_W;
    var denom_pps = pps;
if (denom_pps == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_pps = 1;
}
global.chunk_seconds = chunk_w_px / denom_pps;

    // Rebuild chunk_seq map
    if (variable_global_exists("chunk_seq") && ds_exists(global.chunk_seq, ds_type_map)) {
        ds_map_destroy(global.chunk_seq);
    }
    global.chunk_seq = ds_map_create();

    var sections = global.master_sections;

    // Count how many chunk rooms exist for a stem: rm_chunk_<stem>_00, 01, ...
    function _count_avail_rooms(_stem)
    {
        var count = 0;
        for (var i = 0; i < 200; i++)
        {
            var kk = (i < 10) ? ("0" + string(i)) : string(i);
            var room_name = "rm_chunk_" + _stem + "_" + kk;

            if (asset_get_index(room_name) != -1)
                count++;
            else
                break;
        }
        return max(1, count);
    }

    for (var si = 0; si < array_length(sections); si++)
    {
        var s = sections[si];
        var len_s = s.t1 - s.t0;

        // How many chunk slots this section needs in time
        var denom_chunk_seconds = global.chunk_seconds;
if (denom_chunk_seconds == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_chunk_seconds = 1;
}
var n = ceil(len_s / denom_chunk_seconds);
        if (n < 1) n = 1;

        // Section name -> stem
        var stem = scr_sec_to_stem(s.name);

        // How many chunk ROOMS actually exist for that stem
        var avail = _count_avail_rooms(stem);

        // Build list of chunk keys, WRAPPING
        var arr = array_create(n);
        for (var k = 0; k < n; k++)
        {
            var use_i = k mod avail;
            var kk2 = (use_i < 10) ? ("0" + string(use_i)) : string(use_i);
            arr[k] = stem + "_" + kk2;
        }

        ds_map_add(global.chunk_seq, s.name, arr);
    }
}
