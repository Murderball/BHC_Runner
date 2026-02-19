/// scr_batch_export_load_rooms_from_file(fname)
/// Reads Included File (text) and returns array of room asset IDs.
/// Lines can include commas; blank lines ignored; // comments allowed.
///
/// FIX: Robust path resolution for Included Files + better debug.

function scr_batch_export_load_rooms_from_file(_fname)
{
    var out = [];

    // Try likely locations for included files (sandbox / working dir)
    var paths = [
        _fname,
        working_directory + _fname,
        working_directory + "datafiles/" + _fname
    ];

    var found_path = "";
    for (var p = 0; p < array_length(paths); p++)
    {
        if (file_exists(paths[p]))
        {
            found_path = paths[p];
            break;
        }
    }

    if (found_path == "")
    {
        show_debug_message("[Batch Export] ERROR: rooms file not found: " + _fname);
        show_debug_message("[Batch Export] Tried:");
        for (var p2 = 0; p2 < array_length(paths); p2++)
            show_debug_message("  - " + paths[p2]);
        return out;
    }

    show_debug_message("[Batch Export] rooms file: " + found_path);

    var f = file_text_open_read(found_path);
    while (!file_text_eof(f))
    {
        var line = string_trim(file_text_read_string(f));
        file_text_readln(f);

        if (line == "") continue;
        if (string_copy(line, 1, 2) == "//") continue;

        // allow CSV on a line too
        var parts = string_split(line, ",");
        for (var i = 0; i < array_length(parts); i++)
        {
            var nm = string_trim(parts[i]);
            if (nm == "") continue;

            var rid = asset_get_index(nm);
            if (rid == -1) {
                show_debug_message("[Batch Export] WARNING: room not found: " + nm);
                continue;
            }

            array_push(out, rid);
        }
    }
    file_text_close(f);

    show_debug_message("[Batch Export] loaded rooms=" + string(array_length(out)));
    return out;
}
