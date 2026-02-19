/// scr_markers_load()
/// Loads from persistent save first; falls back to Included Files default if present.
function scr_markers_load()
{
    var fname_save = global.MARKERS_FILE;

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

    // 2) Fallback to default markers.json from Included Files (optional)
    var fname_default = "markers.json"; // your included default (if you have it)
    if (file_exists(fname_default))
    {
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
                    show_debug_message("MARKERS LOAD <- DEFAULT " + fname_default + " count=" + string(array_length(global.markers)));
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