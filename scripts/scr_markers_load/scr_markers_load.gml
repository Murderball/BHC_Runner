/// scr_markers_load()
/// Loads from persistent save first; falls back to Included Files/defaults if present.
function scr_markers_load()
{
    function _markers_from_payload(payload)
    {
        if (is_array(payload)) return payload;

        // Backward-compatible format: { "markers": [...] }
        if (is_struct(payload)
            && variable_struct_exists(payload, "markers")
            && is_array(payload.markers))
        {
            return payload.markers;
        }

        return undefined;
    }

    function _read_text_file(path)
    {
        if (!file_exists(path)) return "";

        if (script_exists(scr_load_text_file)) {
            return string_trim(scr_load_text_file(path));
        }

        var text = "";
        var fd = file_text_open_read(path);
        if (fd >= 0) {
            while (!file_text_eof(fd)) {
                text += file_text_read_string(fd);
                if (!file_text_eof(fd)) file_text_readln(fd);
            }
            file_text_close(fd);
        }

        return string_trim(text);
    }

    if (!variable_global_exists("markers") || !is_array(global.markers)) {
        global.markers = [];
    }

    var lvl = "global";
    if (variable_global_exists("LEVEL_KEY")) {
        lvl = string_lower(string(global.LEVEL_KEY));
        if (lvl == "") lvl = "global";
    }

    var d = "normal";
    if (variable_global_exists("DIFFICULTY")) {
        d = string_lower(string(global.DIFFICULTY));
    }
    else if (variable_global_exists("difficulty")) {
        d = string_lower(string(global.difficulty));
    }
    if (d != "easy" && d != "normal" && d != "hard") {
        d = "normal";
    }

    var fname_save = "markers_save_" + lvl + "_" + d + ".json";
    global.MARKERS_FILE = fname_save;

    // 1) Try persistent save files (level+difficulty first, then legacy names)
    var save_candidates = [
        fname_save,
        "markers_save.json"
    ];
    if (variable_global_exists("markers_file") && is_string(global.markers_file) && global.markers_file != "") {
        array_push(save_candidates, global.markers_file);
    }

    for (var i = 0; i < array_length(save_candidates); i++)
    {
        var save_name = save_candidates[i];
        var json_save = _read_text_file(save_name);
        if (json_save == "") continue;

        try {
            var data_save = json_parse(json_save);
            var loaded_save = _markers_from_payload(data_save);

            if (is_array(loaded_save)) {
                global.markers = loaded_save;
                show_debug_message("MARKERS LOAD <- SAVE " + save_name + " count=" + string(array_length(global.markers)));
                return;
            }

            show_debug_message("MARKERS LOAD: parsed " + save_name + " but markers array was not found.");
        }
        catch (e_save) {
            show_debug_message("MARKERS LOAD: parse failed for " + save_name);
        }
    }

    // 2) Fallback defaults
    var defaults = [
        "story_markers/" + lvl + "_" + d + ".json",
        "story_markers/" + lvl + ".json",
        "story_markers_" + lvl + "_" + d + ".json",
        "story_markers_" + lvl + ".json",
        "story_markers.json",
        "markers.json"
    ];

    for (var j = 0; j < array_length(defaults); j++)
    {
        var def_name = defaults[j];
        var json_def = _read_text_file(def_name);
        if (json_def == "") continue;

        try {
            var data_def = json_parse(json_def);
            var loaded_def = _markers_from_payload(data_def);

            if (is_array(loaded_def)) {
                global.markers = loaded_def;
                show_debug_message("MARKERS LOAD <- DEFAULT " + def_name + " count=" + string(array_length(global.markers)) + " ctx=" + lvl + "/" + d);
                return;
            }

            show_debug_message("MARKERS LOAD: parsed " + def_name + " but markers array was not found.");
        }
        catch (e_def) {
            show_debug_message("MARKERS LOAD: parse failed for " + def_name);
        }
    }

    global.markers = [];
    show_debug_message("MARKERS LOAD: no save/default found. markers cleared.");
}
