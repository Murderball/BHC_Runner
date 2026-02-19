/// scr_markers_load()
/// Loads from persistent save first; falls back to Included Files/defaults if present.
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

    // 1) Try persistent save files (level+difficulty first, then legacy names)
    var save_candidates = [
        fname_save,
        "markers_save.json"
    ];

    if (variable_global_exists("markers_file") && is_string(global.markers_file) && global.markers_file != "") {
        array_push(save_candidates, global.markers_file);
    }

    for (var si = 0; si < array_length(save_candidates); si++)
    {
        var save_name = save_candidates[si];
        if (!file_exists(save_name)) continue;

        var json_save = "";
        if (script_exists(scr_load_text_file)) {
            json_save = string_trim(scr_load_text_file(save_name));
        } else {
            var fs = file_text_open_read(save_name);
            if (fs >= 0) {
                while (!file_text_eof(fs)) {
                    json_save += file_text_read_string(fs);
                    if (!file_text_eof(fs)) file_text_readln(fs);
                }
                file_text_close(fs);
                json_save = string_trim(json_save);
            }
        }

        if (json_save == "") continue;

        try {
            var data_save = json_parse(json_save);
            var loaded_save = undefined;

            if (is_array(data_save)) loaded_save = data_save;
            else if (is_struct(data_save)
                && variable_struct_exists(data_save, "markers")
                && is_array(data_save.markers))
            {
                loaded_save = data_save.markers;
            }

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

    for (var i = 0; i < array_length(defaults); i++)
    {
        var def_name = defaults[i];
        if (!file_exists(def_name)) continue;

        var json_def = "";
        if (script_exists(scr_load_text_file)) {
            json_def = string_trim(scr_load_text_file(def_name));
        } else {
            var fd = file_text_open_read(def_name);
            if (fd >= 0) {
                while (!file_text_eof(fd)) {
                    json_def += file_text_read_string(fd);
                    if (!file_text_eof(fd)) file_text_readln(fd);
                }
                file_text_close(fd);
                json_def = string_trim(json_def);
            }
        }

        if (json_def == "") continue;

        try {
            var data_def = json_parse(json_def);
            var loaded_def = undefined;

            if (is_array(data_def)) loaded_def = data_def;
            else if (is_struct(data_def)
                && variable_struct_exists(data_def, "markers")
                && is_array(data_def.markers))
            {
                loaded_def = data_def.markers;
            }

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

    // 3) Final fallback
    global.markers = [];
    show_debug_message("MARKERS LOAD: no save/default found. markers cleared.");
}
