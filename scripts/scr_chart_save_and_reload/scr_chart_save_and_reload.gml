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
