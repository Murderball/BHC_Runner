/// scr_bg_near_sprite_for_room(room_name)
/// Returns spr_bg_00..spr_bg_08 based on the chunk's position in the full song order.
/// Expects names like: "rm_chunk_intro_00", "rm_chunk_chorus_2_07", etc.
/// Requires sprites: spr_bg_00 ... spr_bg_08

function scr_bg_near_sprite_for_room(_room_name)
{
    var n = string_lower(string(_room_name));

    // --- Parse local index after the LAST underscore ---
    var last_us = string_last_pos("_", n);
    if (last_us <= 0) return spr_bg_easy_00;

    // Copy from after '_' to end of string, then convert to number
    var idx_str = string_copy(n, last_us + 1, string_length(n) - last_us);
    var local_i = real(idx_str);
    if (!is_real(local_i)) local_i = 0;
    local_i = floor(local_i);

    // --- Section start ordinals (continuous from top) ---
    var base = -1;

    if (string_pos("rm_chunk_intro_", n) == 1)              base = 0;
    else if (string_pos("rm_chunk_break_3_", n) == 1)       base = 73;
    else if (string_pos("rm_chunk_break_2_", n) == 1)       base = 48;
    else if (string_pos("rm_chunk_break_", n) == 1)         base = 5;

    else if (string_pos("rm_chunk_main_", n) == 1)          base = 6;

    else if (string_pos("rm_chunk_verse_2_", n) == 1)       base = 42;
    else if (string_pos("rm_chunk_verse_", n) == 1)         base = 14;

    else if (string_pos("rm_chunk_prechorus_2_", n) == 1)   base = 58;
    else if (string_pos("rm_chunk_prechorus_", n) == 1)     base = 22;

    else if (string_pos("rm_chunk_chorus_return_", n) == 1) base = 66;
    else if (string_pos("rm_chunk_chorus_3_", n) == 1)      base = 98;
    else if (string_pos("rm_chunk_chorus_2_", n) == 1)      base = 34;
    else if (string_pos("rm_chunk_chorus_", n) == 1)        base = 26;

    else if (string_pos("rm_chunk_breakdown_2_", n) == 1)   base = 90;
    else if (string_pos("rm_chunk_breakdown_", n) == 1)     base = 50;

    else if (string_pos("rm_chunk_bridge_", n) == 1)        base = 74;
    else if (string_pos("rm_chunk_build_", n) == 1)         base = 82;

    else if (string_pos("rm_chunk_outro_", n) == 1)         base = 106;

    if (base < 0) return spr_bg_easy_00;

    var ordinal = base + local_i;
    var bgi = ordinal mod 9;

    switch (bgi)
    {
        case 0: return spr_bg_easy_00;
        case 1: return spr_bg_easy_01;
        case 2: return spr_bg_easy_02;
        case 3: return spr_bg_easy_03;
        case 4: return spr_bg_easy_04;
        case 5: return spr_bg_easy_05;
        case 6: return spr_bg_easy_06;
        case 7: return spr_bg_easy_07;
        case 8: return spr_bg_easy_08;
    }

    return spr_bg_easy_00;
}