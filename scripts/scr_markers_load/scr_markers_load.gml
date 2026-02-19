/// scr_markers_load()
/// Loads from persistent save first; falls back to Included Files default if present.
function scr_markers_load()
{
    var lvl = "global";
    if (variable_global_exists("LEVEL_KEY")) {
        lvl = string_lower(string(global.LEVEL_KEY));
        if (lvl == "") lvl = "global";
    }

    var d = "normal";
    if (variable_global_exists("DIFFICULTY")) d = string_lower(string(global.DIFFICULTY));
    else if (variable_global_exists("difficulty")) d = string_lower(string(global.difficulty));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    var fname_save = "markers_save_" + lvl + "_" + d + ".json";
    global.MARKERS_FILE = fname_save;

    // 1) Try persistent save file
    if (file_exists(fname_save))
    {
        var f = file_text_open_read(fname_save);
        var json = "";
        while (!file_text_eof(f)) json += file_text_read_string(f);
        file_text_close(f);

        json = string_trim(json);

        if (json != "")
        {
            try {
                var data = json_parse(json);

                // Expecting array
                if (is_array(data)) {
                    global.markers = data;
                    show_debug_message("MARKERS LOAD <- SAVE " + fname_save + " count=" + string(array_length(global.markers)));
                    return;
                } else {
                    show_debug_message("MARKERS LOAD: save file parsed but not an array (resetting).");
                }
            }
            catch (e) {
                show_debug_message("MARKERS LOAD: parse failed for save file " + fname_save);
            }
        }
        else show_debug_message("MARKERS LOAD: save file empty " + fname_save);
    }

    // 2) Fallback to level/difficulty defaults from Included Files
    var defaults = [
        "story_markers/" + lvl + "_" + d + ".json",
        "story_markers/" + lvl + ".json",
        "story_markers_" + lvl + "_" + d + ".json",
        "story_markers_" + lvl + ".json",
        "story_markers.json",
        "markers.json"
    ];

    for (var i = 0; i < array_length(defaults); i++)
    {
        var fname_default = defaults[i];
        if (!file_exists(fname_default)) continue;

        var buf = buffer_load(fname_default);
        var json2 = buffer_read(buf, buffer_text);
        buffer_delete(buf);

        json2 = string_trim(json2);

        if (json2 != "")
        {
            try {
                var data2 = json_parse(json2);
                if (is_array(data2)) {
                    global.markers = data2;
                    show_debug_message("MARKERS LOAD <- DEFAULT " + fname_default + " count=" + string(array_length(global.markers)) + " ctx=" + lvl + "/" + d);
                    return;
                }
            } catch (e2) {
                show_debug_message("MARKERS LOAD: parse failed for default " + fname_default);
            }
        }
    }

    // 3) Final fallback
    global.markers = [];
    show_debug_message("MARKERS LOAD: no save/default found. markers cleared.");
}
