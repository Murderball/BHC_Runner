/// scr_apply_difficulty_change(new_diff, optional_level_key)
function scr_apply_difficulty_change(new_diff, optional_level_key)
{
    var d = string_lower(string(new_diff));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    var explicit_key = "";
    if (!is_undefined(optional_level_key)) explicit_key = string_lower(string(optional_level_key));

    var lk = explicit_key;
    if (lk == "" && script_exists(scr_active_level_key)) lk = scr_active_level_key();
    if (lk == "" && variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)) lk = string_lower(global.LEVEL_KEY);

    scr_media_trace("scr_apply_difficulty_change", lk, d, -1);

    // If nothing changes, bail
    if (variable_global_exists("difficulty") && string_lower(string(global.difficulty)) == d) return;

    // Keep both synced
    global.difficulty = d;
    global.DIFFICULTY = d;

    // Ensure we have a valid level key (used for charts)
    if (lk == "") return;
    global.LEVEL_KEY = lk;

    var __level_idx = real(string_copy(lk, 6, string_length(lk) - 5));
    if (__level_idx < 1) return;

    __level_idx = clamp(__level_idx, 1, 99);

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
        if (script_exists(scr_chunk_refresh_visual_for_difficulty)) {
            scr_chunk_refresh_visual_for_difficulty(d);
        } else {
            if (variable_global_exists("DIFF_REFRESH_NEEDS_RESTAMP") && global.DIFF_REFRESH_NEEDS_RESTAMP)
                global.force_chunk_refresh = true;

            global.bg_repaint_all = true;
        }
    }

    // --- AUDIO SWITCH ---
    if (variable_global_exists("diff_swap_audio") && global.diff_swap_audio)
    {
        if (script_exists(scr_set_difficulty_song))
            scr_set_difficulty_song(d, "diff_change", lk);
    }

    show_debug_message("[DIFF] change -> " + d + " level=" + string(lk));
}
