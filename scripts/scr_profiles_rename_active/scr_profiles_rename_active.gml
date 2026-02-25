/// scr_profiles_rename_active(name)
function scr_profiles_rename_active(_name)
{
    var _nm = string(_name);
    if (_nm == "") return false;
    if (!variable_global_exists("profiles_data") || !is_struct(global.profiles_data)) return false;

    for (var i = 0; i < array_length(global.profiles_data.profiles); i++) {
        var p = global.profiles_data.profiles[i];
        if (is_struct(p) && p.id == global.profiles_data.active_profile_id) {
            p.name = _nm;
            p.updated_at = current_time;
            global.profiles_data.profiles[i] = p;
            return true;
        }
    }
    return false;
}
