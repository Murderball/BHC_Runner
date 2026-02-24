/// scr_apply_difficulty_change(new_diff)
function scr_apply_difficulty_change(new_diff)
{
    var d = string_lower(string(new_diff));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    // If nothing changes, bail
    if (variable_global_exists("difficulty") && string_lower(string(global.difficulty)) == d) return;

    // Keep both synced
    global.difficulty = d;
    global.DIFFICULTY = d;

    // -------------------------------------------------
    // Ensure we have a valid level key (used for charts)
    // -------------------------------------------------
    var lk = "";

    var room_name_now = string_lower(string(room_get_name(room)));
    var room_pos = string_pos("rm_level", room_name_now);
    if (room_pos == 1) {
        var room_digits = string_copy(room_name_now, room_pos + 8, 2);
        if (string_length(room_digits) == 2 && string_digits(room_digits) == room_digits) lk = "level" + room_digits;
    }

    if (lk == "" && variable_global_exists("editor_chart_path")) {
        var chart_path_now = string_lower(string(global.editor_chart_path));
        var level_pos = string_pos("charts/level", chart_path_now);
        if (level_pos > 0) {
            var path_digits = string_copy(chart_path_now, level_pos + 11, 2);
            if (string_length(path_digits) == 2 && string_digits(path_digits) == path_digits) lk = "level" + path_digits;
        }
    }

    if (lk == "" && variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)) {
        var lk_existing = string_lower(string(global.LEVEL_KEY));
        if (string_length(lk_existing) == 7 && string_pos("level", lk_existing) == 1) {
            var existing_digits = string_copy(lk_existing, 6, 2);
            if (string_length(existing_digits) == 2 && string_digits(existing_digits) == existing_digits) {
                lk = lk_existing;
            }
        }
    }

    if (lk == "") lk = "level01";
    global.LEVEL_KEY = lk;

    // -------------------------------------------------
    // Rebuild DIFF_CHART per level so chart swaps
    // don't accidentally keep Level 3 paths on Level 1.
    // -------------------------------------------------
    var __level_idx = 1;
    if (string_length(lk) == 7 && string_pos("level", lk) == 1) {
        var lk_digits = string_copy(lk, 6, 2);
        if (string_length(lk_digits) == 2 && string_digits(lk_digits) == lk_digits) {
            __level_idx = clamp(real(lk_digits), 1, 6);
        }
    }
    global.DIFF_CHART = {
        easy   : scr_chart_fullpath(scr_chart_filename(__level_idx, "easy", false)),
        normal : scr_chart_fullpath(scr_chart_filename(__level_idx, "normal", false)),
        hard   : scr_chart_fullpath(scr_chart_filename(__level_idx, "hard", false))
    };

    // Apply chart_file for this diff
    global.chart_file = global.DIFF_CHART[$ d];

    // Reload chart NOW (so difficulty really changes gameplay)
    if (script_exists(scr_chart_load)) scr_chart_load();

    // --- VISUAL / TILEMAP SWITCH ---
    if (variable_global_exists("diff_swap_visual") && global.diff_swap_visual)
    {
        // Prefer your existing system if present
        if (script_exists(scr_chunk_refresh_visual_for_difficulty))
        {
            scr_chunk_refresh_visual_for_difficulty(d);
        }
        else
        {
            // Soft fallback: request refresh flags if your renderer watches them
            if (variable_global_exists("DIFF_REFRESH_NEEDS_RESTAMP") && global.DIFF_REFRESH_NEEDS_RESTAMP)
                global.force_chunk_refresh = true;

            global.bg_repaint_all = true;
        }
    }

    // --- AUDIO SWITCH ---
    if (variable_global_exists("diff_swap_audio") && global.diff_swap_audio)
    {
        if (script_exists(scr_set_difficulty_song))
            scr_set_difficulty_song(d, "diff_change");
    }

    show_debug_message("[DIFF] change -> " + d + " level=" + string(lk));
}
