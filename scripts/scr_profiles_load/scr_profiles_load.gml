/// scr_profiles_load()
function scr_profiles_load()
{
    if (!script_exists(scr_profiles_ensure_defaults)) return false;
    scr_profiles_ensure_defaults();

    if (!directory_exists(global.profiles_file_dir)) directory_create(global.profiles_file_dir);

    var _ok = false;
    if (file_exists(global.profiles_file_path)) {
        var _buf = buffer_load(global.profiles_file_path);
        if (_buf >= 0) {
            var _raw = buffer_read(_buf, buffer_string);
            buffer_delete(_buf);
            if (_raw != "") {
                var _parsed = json_parse(_raw);
                if (is_struct(_parsed)) {
                    global.profiles_data = _parsed;
                    _ok = true;
                }
            }
        }
    }

    if (!_ok) {
        global.profiles_data = { version: global.profiles_version, active_profile_id: "", profiles: [] };
    }

    scr_profiles_ensure_defaults();
    if (!_ok) scr_profiles_save();

    return true;
}
