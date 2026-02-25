/// scr_profiles_save()
function scr_profiles_save()
{
    if (!script_exists(scr_profiles_ensure_defaults)) return false;
    scr_profiles_ensure_defaults();

    if (!directory_exists(global.profiles_file_dir)) directory_create(global.profiles_file_dir);

    var _txt = json_stringify(global.profiles_data);
    var _buf = buffer_create(string_byte_length(_txt) + 1, buffer_fixed, 1);
    buffer_write(_buf, buffer_string, _txt);
    buffer_save(_buf, global.profiles_file_path);
    buffer_delete(_buf);
    return true;
}
