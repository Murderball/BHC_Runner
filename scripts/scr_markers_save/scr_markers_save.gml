/// scr_markers_save()
function scr_markers_save()
{
    if (!variable_global_exists("markers") || !is_array(global.markers)) global.markers = [];

    var lvl = "global";
    if (variable_global_exists("LEVEL_KEY")) {
        lvl = string_lower(string(global.LEVEL_KEY));
        if (lvl == "") lvl = "global";
    }

    var d = "normal";
    if (variable_global_exists("DIFFICULTY")) d = string_lower(string(global.DIFFICULTY));
    else if (variable_global_exists("difficulty")) d = string_lower(string(global.difficulty));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    var fname = "markers_save_" + lvl + "_" + d + ".json";
    global.MARKERS_FILE = fname;

    // Convert to JSON text
    var json = json_stringify(global.markers);

    // Write into SAVE area (persistent)
    var f = file_text_open_write(fname);
    file_text_write_string(f, json);
    file_text_close(f);

    show_debug_message("MARKERS SAVE -> " + fname + " bytes=" + string(string_length(json)) + " ctx=" + lvl + "/" + d);
}
