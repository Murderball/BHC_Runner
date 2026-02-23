/// scr_apply_difficulty(diff, reason, swap_visual, swap_audio)
function scr_apply_difficulty(_diff, _reason, _swap_visual, _swap_audio)
{
    if (is_undefined(_swap_visual)) _swap_visual = true;
    if (is_undefined(_swap_audio))  _swap_audio  = true;
    if (is_undefined(_reason))      _reason = "unknown";

    var d = string_lower(string(_diff));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    if (!variable_global_exists("last_diff_applied")) global.last_diff_applied = "";
    if (!variable_global_exists("last_chart_key_loaded")) global.last_chart_key_loaded = "";

    var same = (global.last_diff_applied == d);

    global.DIFFICULTY = d;
    global.difficulty = d;
    global.bg_difficulty = d;

    var level_idx = 3;
    if (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY) && string_length(global.LEVEL_KEY) >= 6) {
        level_idx = clamp(real(string_copy(global.LEVEL_KEY, 6, string_length(global.LEVEL_KEY)-5)), 1, 6);
    }

    var chart_path = scr_chart_resolve_for_level(level_idx, d, false);
    if (chart_path != "") {
        global.chart_file = chart_path;
    }

    var chart_key = string(level_idx) + "|" + d + "|main";
    var should_reload_chart = (global.last_chart_key_loaded != chart_key);

    if (_swap_visual)
    {
        global.bg_repaint_all = true;
        var _di = (d == "easy") ? 0 : ((d == "hard") ? 2 : 1);
        global.bg_diff_i = _di;
        if (script_exists(scr_set_difficulty_visuals)) scr_set_difficulty_visuals(d);
        if (variable_global_exists("DIFF_REFRESH_NEEDS_RESTAMP") && global.DIFF_REFRESH_NEEDS_RESTAMP) {
            global.force_chunk_refresh = true;
        }
    }

    if (should_reload_chart && script_exists(scr_chart_load)) {
        scr_chart_load();
        global.last_chart_key_loaded = chart_key;
    }

    if (_swap_audio)
    {
        var switched = scr_song_switch_for_difficulty(global.LEVEL_KEY, d);
        if (!scr_song_is_valid_inst(switched) && variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] diff switch kept current audio (invalid target asset)");
        }
    }

    global.last_diff_applied = d;

    if (script_exists(scr_markers_load)) scr_markers_load();
    if (script_exists(scr_story_events_from_markers)) scr_story_events_from_markers();
    if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();

    show_debug_message("[DIFF] apply -> " + d + " (" + string(_reason) + ")"
        + " same=" + string(same) + " V=" + string(_swap_visual) + " A=" + string(_swap_audio));
}
