/// scr_profiles_save()
function scr_profiles_save()
{
    scr_profiles_ensure_defaults();

    // Update timestamps if desired, but do not crash if missing
    if (variable_global_exists("profiles_data") && is_struct(global.profiles_data)) {
        // ok
    } else {
        return;
    }

    var json = "";
    try {
        json = json_stringify(global.profiles_data);
    } catch (e) {
        show_debug_message("[PROFILES] save stringify failed: " + string(e));
        return;
    }

    var fh = -1;
    try {
        fh = file_text_open_write(global.profiles_file_path);
        file_text_write_string(fh, json);
        file_text_close(fh);
    } catch (e2) {
        if (fh != -1) file_text_close(fh);
        show_debug_message("[PROFILES] save write failed: " + string(e2));
    }
}
