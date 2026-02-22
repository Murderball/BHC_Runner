function scr_chart_save_and_reload(fname)
{
    if (is_undefined(fname) || fname == "") return;

    // Ensure chart array exists
    if (!variable_global_exists("chart") || !is_array(global.chart)) global.chart = [];

    // ------------------------------------------------------------
    // Normalize filenames so EVERYTHING uses:
    //   charts/level03/easy.json
    //   charts/level03/normal_v2.json
    //   charts/level03/hard.json
    //
    // Your project previously used legacy names like:
    //   level03_hard.json  -> charts/level03_hard.json (WRONG)
    // This fix maps them to the correct subfolder paths.
    // ------------------------------------------------------------
    var path = string(fname);

    // If caller passed just a filename (no folder), map legacy names
    var has_slash = (string_pos("/", path) > 0) || (string_pos("\\", path) > 0);

    if (!has_slash)
    {
        if (path == "level01_easy.json")            path = "charts/level01/easy.json";
        else if (path == "level03_normal_v2.json")  path = "charts/level03/normal_v2.json";
        else if (path == "level03_hard_v2.json")       path = "charts/level03/hard_v2.json";
        else if (string_pos("charts/", path) != 1)  path = "charts/" + path;
    }
    else
    {
        // Ensure it's under charts/
        if (string_pos("charts/", path) != 1) path = "charts/" + path;
    }

    // Ensure folders exist in sandbox
    directory_create("charts");
    if (string_pos("charts/level01/", path) == 1) directory_create("charts/level01");
    if (string_pos("charts/level03/", path) == 1) directory_create("charts/level03");

    // If chart is empty, don't overwrite the target file with nothing
    if (array_length(global.chart) == 0)
    {
        show_debug_message("[chart] Refusing to save EMPTY chart. Switching load only -> " + string(path));
        global.chart_file = path;
        if (script_exists(scr_chart_load)) scr_chart_load();
        return;
    }

    // Safe fallbacks
    var bpm = 140;
    if (variable_global_exists("BPM")) bpm = global.BPM;

    var off = 0.0;
    if (variable_global_exists("OFFSET")) off = global.OFFSET;

    // Standard format: { bpm, offset, notes:[...] }
    var out = { bpm: bpm, offset: off, notes: global.chart };
    var json_txt = json_stringify(out);

    var fh = file_text_open_write(path);
    if (fh < 0)
    {
        show_debug_message("[chart] ERROR: failed to open for write: " + string(path));
        return;
    }

    file_text_write_string(fh, json_txt);
    file_text_close(fh);

    show_debug_message("[chart] Saved: " + string(path));

    // Reload immediately from the SAME path difficulty will use
    global.chart_file = path;
    if (script_exists(scr_chart_load)) scr_chart_load();

    if (variable_global_exists("sel")) global.sel = [];
}

function scr_editor_resolve_variant_chart_path(_variant_name)
{
    var v = string_lower(string(_variant_name));

    var level_key = "level03";
    if (variable_global_exists("LEVEL_KEY") && string(global.LEVEL_KEY) != "") {
        level_key = string_lower(string(global.LEVEL_KEY));
    }

    var candidates = [];

    // Prefer DIFF_CHART mapping if present, but add robust fallbacks for _v2 and legacy names.
    if (variable_global_exists("DIFF_CHART") && is_struct(global.DIFF_CHART))
    {
        if (variable_struct_exists(global.DIFF_CHART, v)) {
            array_push(candidates, string(global.DIFF_CHART[$ v]));
        }
    }

    if (v == "easy")
    {
        array_push(candidates, "charts/" + level_key + "/easy.json");
        array_push(candidates, "charts/" + level_key + "_easy.json");
    }
    else if (v == "normal")
    {
        array_push(candidates, "charts/" + level_key + "/normal_v2.json");
        array_push(candidates, "charts/" + level_key + "/normal.json");
        array_push(candidates, "charts/" + level_key + "_normal_v2.json");
        array_push(candidates, "charts/" + level_key + "_normal.json");
    }
    else if (v == "hard")
    {
        array_push(candidates, "charts/" + level_key + "/hard_v2.json");
        array_push(candidates, "charts/" + level_key + "/hard.json");
        array_push(candidates, "charts/" + level_key + "_hard_v2.json");
        array_push(candidates, "charts/" + level_key + "_hard.json");
    }

    // Normalize candidate paths and return first real file.
    for (var i = 0; i < array_length(candidates); i++)
    {
        var c = string(candidates[i]);
        if (c == "") continue;

        if (string_pos("charts/", c) != 1 && string_pos("datafiles/", c) != 1) c = "charts/" + c;

        if (file_exists(c)) return c;

        var data_c = "datafiles/" + c;
        if (file_exists(data_c)) return c; // scr_chart_load already tries datafiles/ fallback.
    }

    // Nothing exists on disk; return best default so logging can explain the miss.
    if (array_length(candidates) > 0) {
        var fallback = string(candidates[0]);
        if (string_pos("charts/", fallback) != 1 && string_pos("datafiles/", fallback) != 1) fallback = "charts/" + fallback;
        return fallback;
    }

    return "";
}

/// scr_editor_switch_chart_variant(variant_index)
/// variant_index mapping: 1=easy, 2=normal, 3=hard, 4=boss
function scr_editor_switch_chart_variant(_variant_index)
{
    var idx = floor(_variant_index);
    var variant_name = "normal";
    if (idx == 1) variant_name = "easy";
    else if (idx == 2) variant_name = "normal";
    else if (idx == 3) variant_name = "hard";
    else if (idx == 4) variant_name = "boss";

    var resolved_path = "";
    if (variant_name == "boss") {
        if (variable_global_exists("BOSS_CHART_FILE")) resolved_path = string(global.BOSS_CHART_FILE);
    } else {
        resolved_path = scr_editor_resolve_variant_chart_path(variant_name);
    }

    if (resolved_path == "") {
        show_debug_message("[editor chart switch] FAIL idx=" + string(idx)
            + " variant=" + variant_name
            + " reason=no_chart_path");
        return false;
    }

    var file_ok = file_exists(resolved_path) || file_exists("datafiles/" + resolved_path);
    show_debug_message("[editor chart switch] idx=" + string(idx)
        + " variant=" + variant_name
        + " path=" + resolved_path
        + " exists=" + string(file_ok));

    if (!file_ok)
    {
        show_debug_message("[editor chart switch] FAIL idx=" + string(idx)
            + " variant=" + variant_name
            + " reason=file_missing path=" + resolved_path);
        return false;
    }

    if (variant_name != "boss")
    {
        global.DIFFICULTY = variant_name;
        global.difficulty = variant_name;
    }

    global.chart_file = resolved_path;

    if (script_exists(scr_chart_load)) {
        scr_chart_load();
    } else {
        show_debug_message("[editor chart switch] FAIL idx=" + string(idx)
            + " variant=" + variant_name
            + " reason=scr_chart_load_missing");
        return false;
    }

    // Refresh editor/runtime caches so the loaded chart is immediately visible/usable.
    if (script_exists(scr_editor_selection_clear)) scr_editor_selection_clear();
    if (script_exists(scr_autohit_reset)) scr_autohit_reset();
    if (script_exists(scr_attack_timeline_build)) scr_attack_timeline_build();

    if (variable_global_exists("editor_time") && variable_global_exists("CHART_LEN_S") && is_real(global.CHART_LEN_S)) {
        global.editor_time = clamp(global.editor_time, 0, max(0, global.CHART_LEN_S));
    }

    var note_count = (variable_global_exists("chart") && is_array(global.chart)) ? array_length(global.chart) : -1;
    show_debug_message("[editor chart switch] SUCCESS idx=" + string(idx)
        + " variant=" + variant_name
        + " path=" + string(global.chart_file)
        + " notes=" + string(note_count));

    return true;
}
