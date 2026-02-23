/// scr_apply_difficulty(diff, reason, swap_visual, swap_audio)
function scr_apply_difficulty(_diff, _reason, _swap_visual, _swap_audio)
{
    // Defaults so old callers don't break
    if (is_undefined(_swap_visual)) _swap_visual = true;
    if (is_undefined(_swap_audio))  _swap_audio  = true;
    if (is_undefined(_reason))      _reason = "unknown";

    var d = string_lower(string(_diff));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    var same = (variable_global_exists("DIFFICULTY") && string_lower(string(global.DIFFICULTY)) == d);

    // Always keep both globals synced
    global.DIFFICULTY = d;
    global.difficulty = d;

    // Always keep BG diff synced (visual swap still gated below)
    global.bg_difficulty = d;

    // -----------------
    // 1) Set chart file (ALWAYS)
    // -----------------
    if (variable_global_exists("DIFF_CHART") && is_struct(global.DIFF_CHART))
    {
        if (variable_struct_exists(global.DIFF_CHART, d))
        {
            global.chart_file = global.DIFF_CHART[$ d];
        }
    }

    // During startup/boot, do NOT force chart reload here (obj_game already calls scr_chart_load)
    var startup = (variable_global_exists("STARTUP_LOADING") && global.STARTUP_LOADING);
    var is_boot = (string_lower(string(_reason)) == "boot");

    // If not boot/startup and difficulty changed, reload chart now
    if (!startup && !is_boot && !same)
    {
        if (script_exists(scr_chart_load)) scr_chart_load();
    }

    // Story markers are level+difficulty scoped; refresh when context changes.
    var lvl = "global";
    if (variable_global_exists("LEVEL_KEY")) {
        lvl = string_lower(string(global.LEVEL_KEY));
        if (lvl == "") lvl = "global";
    }

    var markers_level = "";
    if (variable_global_exists("MARKERS_LEVEL_KEY")) {
        markers_level = string_lower(string(global.MARKERS_LEVEL_KEY));
    }

    var markers_diff = "";
    if (variable_global_exists("MARKERS_DIFFICULTY")) {
        markers_diff = string_lower(string(global.MARKERS_DIFFICULTY));
    }

    var marker_context_changed = (markers_level != lvl) || (markers_diff != d);
    if (!same || marker_context_changed)
    {
        if (script_exists(scr_markers_load)) scr_markers_load();
        if (script_exists(scr_story_events_from_markers)) scr_story_events_from_markers();
        if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
    }

    // -----------------
    // 2) Visual domain (GATED)
    // -----------------
    if (_swap_visual)
    {
        global.bg_repaint_all = true;

	// --- BACKGROUND DIFFICULTY (your BG system uses bg_diff_i, not bg_difficulty) ---
	var _di = 1;
	if (d == "easy") _di = 0;
	else if (d == "hard") _di = 2;
	else _di = 1;

	global.bg_diff_i = _di;
	global.bg_difficulty = d; // keep this too (for anything else)

	// IMPORTANT: force repaint even if CI didn't change
	// scr_bg_paint_slot() has a guard using bg_slot_last_ci; reset it so repaint works
	if (variable_global_exists("bg_slot_near") && is_array(global.bg_slot_near))
	{
	    global.bg_slot_last_ci = array_create(array_length(global.bg_slot_near), -999999);
	}

	// Request repaint (chunk manager will run scr_bg_repaint_all_slots once)
	global.bg_repaint_all = true;

        if (script_exists(scr_set_difficulty_visuals))
        {
            scr_set_difficulty_visuals(d);
        }
        else
        {
            // Fallback: manual visibility toggle using cached layer IDs
            var show_easy   = (d == "easy");
            var show_normal = (d == "normal");
            var show_hard   = (d == "hard");

            if (variable_global_exists("layer_vis_easy_id")   && global.layer_vis_easy_id   != -1) layer_set_visible(global.layer_vis_easy_id,   show_easy);
            if (variable_global_exists("layer_vis_normal_id") && global.layer_vis_normal_id != -1) layer_set_visible(global.layer_vis_normal_id, show_normal);
            if (variable_global_exists("layer_vis_hard_id")   && global.layer_vis_hard_id   != -1) layer_set_visible(global.layer_vis_hard_id,   show_hard);
        }

        if (variable_global_exists("DIFF_REFRESH_NEEDS_RESTAMP") && global.DIFF_REFRESH_NEEDS_RESTAMP)
        {
            global.force_chunk_refresh = true;
        }
    }

    // -----------------
    // 3) Audio domain (GATED)
    // -----------------
    if (_swap_audio && (!same || string_lower(string(_reason)) == "editor_switch"))
    {
        if (script_exists(scr_set_difficulty_song))
        {
            scr_set_difficulty_song(d, _reason);
        }
    }

    show_debug_message("[DIFF] apply -> " + d + " (" + string(_reason) + ")"
        + " same=" + string(same) + " V=" + string(_swap_visual) + " A=" + string(_swap_audio));
}
