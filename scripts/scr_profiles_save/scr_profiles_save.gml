/// scr_profiles_save()
function scr_profiles_save()
{
    if (!script_exists(scr_profiles_ensure_defaults)) return false;
    scr_profiles_ensure_defaults();

    if (!directory_exists(global.profiles_file_dir)) {
        directory_create(global.profiles_file_dir);
    }

    if (!directory_exists(global.profiles_file_dir)) return false;

    var _txt = json_stringify(global.profiles_data);
    var _file = file_text_open_write(global.profiles_file_path);

    if (_file < 0) return false;

    file_text_write_string(_file, _txt);
    file_text_close(_file);
    return true;
}
