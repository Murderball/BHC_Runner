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

    // Primary save (level+difficulty)
    var f = file_text_open_write(fname);
    file_text_write_string(f, json);
    file_text_close(f);

    // Compatibility save paths so older load paths/editor defaults still pick up latest markers
    var legacy_names = ["markers_save.json"];
    if (variable_global_exists("markers_file") && is_string(global.markers_file) && global.markers_file != "") {
        array_push(legacy_names, global.markers_file);
    }

    for (var i = 0; i < array_length(legacy_names); i++)
    {
        var lf = legacy_names[i];
        var f2 = file_text_open_write(lf);
        file_text_write_string(f2, json);
        file_text_close(f2);
    }

    show_debug_message("MARKERS SAVE -> " + fname + " bytes=" + string(string_length(json)) + " ctx=" + lvl + "/" + d);
}
