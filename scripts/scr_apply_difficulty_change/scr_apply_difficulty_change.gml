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
    if (string_pos("rm_level", room_name_now) == 1 && string_length(room_name_now) >= 10) {
        var room_digits = string_copy(room_name_now, 9, 2);
        if (string_digits(room_digits) == room_digits) lk = "level" + room_digits;
    }

    if (lk == "" && variable_global_exists("editor_chart_path")) {
        var chart_path_now = string_lower(string(global.editor_chart_path));
        var level_pos = string_pos("charts/level", chart_path_now);
        if (level_pos > 0) {
            var path_digits = string_copy(chart_path_now, level_pos + string_length("charts/level"), 2);
            if (string_digits(path_digits) == path_digits) lk = "level" + path_digits;
        }
    }

    if (lk == "" && variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)) {
        lk = string_lower(string(global.LEVEL_KEY));
    }

    if (lk == "") lk = "level01";
    global.LEVEL_KEY = lk;

    // -------------------------------------------------
    // Rebuild DIFF_CHART per level so chart swaps
    // don't accidentally keep Level 3 paths on Level 1.
    // -------------------------------------------------
    var __level_idx = clamp(real(string_copy(lk, 6, string_length(lk) - 5)), 1, 6);
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
