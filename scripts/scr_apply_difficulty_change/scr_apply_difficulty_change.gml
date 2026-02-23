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
    var lk = "level03";
    if (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)) lk = global.LEVEL_KEY;
    else global.LEVEL_KEY = lk;

    // -------------------------------------------------
    // Rebuild DIFF_CHART per level so chart swaps
    // don't accidentally keep Level 3 paths on Level 1.
    // -------------------------------------------------
    var lvl_num = 3;
    if (string_length(lk) >= 6) lvl_num = max(1, real(string_copy(lk, 6, string_length(lk) - 5)));
    var lvl_num_str = string(floor(lvl_num));

    global.DIFF_CHART = {
        easy   : "charts/" + lk + "/level" + lvl_num_str + "_easy.json",
        normal : "charts/" + lk + "/level" + lvl_num_str + "_normal.json",
        hard   : "charts/" + lk + "/level" + lvl_num_str + "_hard.json"
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
