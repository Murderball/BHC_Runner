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

        if (json != "")
        {
            try {
                var data = json_parse(json);

                var loaded_markers = _markers_from_payload(data);
                if (is_array(loaded_markers)) {
                    global.markers = loaded_markers;
                    show_debug_message("MARKERS LOAD <- SAVE " + fname_save + " count=" + string(array_length(global.markers)));
                    return;
                } else {
                    show_debug_message("MARKERS LOAD: save file parsed but markers array was not found (resetting).");
                }
            }
            catch (e) {
                show_debug_message("MARKERS LOAD: parse failed for save file " + fname_save);
            }
        }
        else show_debug_message("MARKERS LOAD: save file empty " + fname_save);
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
                var loaded_markers2 = _markers_from_payload(data2);
                if (is_array(loaded_markers2)) {
                    global.markers = loaded_markers2;
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
