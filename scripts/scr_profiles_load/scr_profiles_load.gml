/// scr_profiles_load()
function scr_profiles_load()
{
    scr_profiles_ensure_defaults();

    var loaded_ok = false;

    if (file_exists(global.profiles_file_path)) {
        var raw = "";
        var fh = -1;

        try {
            fh = file_text_open_read(global.profiles_file_path);
            while (!file_text_eof(fh)) {
                raw += file_text_read_string(fh);
                if (!file_text_eof(fh)) raw += "\n";
                file_text_readln(fh);
            }
            file_text_close(fh);
            fh = -1;
        } catch (e) {
            if (fh != -1) file_text_close(fh);
            show_debug_message("[PROFILES] load read failed: " + string(e));
            raw = "";
        }

        if (raw != "") {
            try {
                var parsed = json_parse(raw);
                if (is_struct(parsed)) {
                    global.profiles_data = parsed;
                    loaded_ok = true;
                }
            } catch (e2) {
                show_debug_message("[PROFILES] load parse failed: " + string(e2));
            }
        }
    }

    if (!loaded_ok) {
        global.profiles_data = {
            version : 1,
            active_profile_id : "",
            profiles : []
        };
        scr_profiles_ensure_defaults();
        scr_profiles_save();
    } else {
        scr_profiles_ensure_defaults();
    }

    return loaded_ok;
}
