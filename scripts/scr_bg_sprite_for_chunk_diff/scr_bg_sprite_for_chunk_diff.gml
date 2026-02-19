/// scr_bg_sprite_for_chunk_diff(chunk_name, diff, is_far)
/// FAST + CORRECT:
/// - Preserves section base mapping (intro/break/etc)
/// - Uses 0..44 (mod 45)
/// - Uses cached sprites (no runtime asset_get_index spam)

function scr_bg_sprite_for_chunk_diff(_chunk_name, _diff, _is_far)
{
    // Ensure cache exists
    if (!variable_global_exists("BG_CACHE_READY") || !global.BG_CACHE_READY)
    {
        if (script_exists(scr_bg_cache_init)) scr_bg_cache_init();
    }

    var n = string_lower(string(_chunk_name));

    // parse local index after last '_' (rm_chunk_intro_03 -> 3)
    var last_us = string_last_pos("_", n);
    var local_i = 0;
    if (last_us > 0)
    {
        var idx_str = string_copy(n, last_us + 1, string_length(n) - last_us);
        local_i = floor(real(idx_str));
        if (!is_real(local_i)) local_i = 0;
    }

    // base ordinals (your continuous list)
    var base = 0;

    if (string_pos("rm_chunk_intro_", n) == 1)              base = 0;
    else if (string_pos("rm_chunk_break_", n) == 1)         base = 5;
    else if (string_pos("rm_chunk_main_", n) == 1)          base = 6;
    else if (string_pos("rm_chunk_verse_", n) == 1)         base = 14;
    else if (string_pos("rm_chunk_prechorus_", n) == 1)     base = 22;
    else if (string_pos("rm_chunk_chorus_", n) == 1)        base = 26;
    else if (string_pos("rm_chunk_chorus_2_", n) == 1)      base = 34;
    else if (string_pos("rm_chunk_verse_2_", n) == 1)       base = 42;
    else if (string_pos("rm_chunk_break_2_", n) == 1)       base = 48;
    else if (string_pos("rm_chunk_breakdown_", n) == 1)     base = 50;
    else if (string_pos("rm_chunk_prechorus_2_", n) == 1)   base = 58;
    else if (string_pos("rm_chunk_chorus_return_", n) == 1) base = 66;
    else if (string_pos("rm_chunk_break_3_", n) == 1)       base = 73;
    else if (string_pos("rm_chunk_bridge_", n) == 1)        base = 74;
    else if (string_pos("rm_chunk_build_", n) == 1)         base = 82;
    else if (string_pos("rm_chunk_breakdown_2_", n) == 1)   base = 90;
    else if (string_pos("rm_chunk_chorus_3_", n) == 1)      base = 98;
    else if (string_pos("rm_chunk_outro_", n) == 1)         base = 106;

    // final BG index 0..44 looping
    var bgi = (base + local_i) mod 45;
    if (bgi < 0) bgi += 45;

    // diff -> cache index
    var d = string_lower(string(_diff));
    var di = 0;
    if (d == "normal") di = 1;
    else if (d == "hard") di = 2;

    var spr = _is_far ? global.BG_CACHE_FAR[di][bgi] : global.BG_CACHE_NEAR[di][bgi];
    if (spr == -1) spr = asset_get_index("spr_bg_easy_00");
    return spr;
}