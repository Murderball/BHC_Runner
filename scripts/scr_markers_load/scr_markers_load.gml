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

    function _read_text_file(fname)
    {
        if (!file_exists(fname)) return "";

        if (script_exists(scr_load_text_file)) {
            return string_trim(scr_load_text_file(fname));
        }

        var f = file_text_open_read(fname);
        if (f < 0) return "";

        var txt = "";
        while (!file_text_eof(f)) {
            txt += file_text_read_string(f);
            if (!file_text_eof(f)) file_text_readln(f);
        }
        file_text_close(f);

        return string_trim(txt);
    }

    function _try_load_file(fname, from_save)
    {
        var json = _read_text_file(fname);
        if (json == "") return false;

        try {
            var data = json_parse(json);
            var loaded = _markers_from_payload(data);
            if (is_array(loaded)) {
                global.markers = loaded;
                if (from_save)
                    show_debug_message("MARKERS LOAD <- SAVE " + fname + " count=" + string(array_length(global.markers)));
                else
                    show_debug_message("MARKERS LOAD <- DEFAULT " + fname + " count=" + string(array_length(global.markers)));
                return true;
            }

            show_debug_message("MARKERS LOAD: parsed " + fname + " but markers array was not found.");
        }
        catch (e) {
            show_debug_message("MARKERS LOAD: parse failed for " + fname);
        }

        return false;
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

    for (var si = 0; si < array_length(save_candidates); si++)
    {
        if (_try_load_file(save_candidates[si], true)) return;
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
        if (_try_load_file(defaults[i], false)) return;
    }

    // 3) Final fallback
    global.markers = [];
    show_debug_message("MARKERS LOAD: no save/default found. markers cleared.");
}
