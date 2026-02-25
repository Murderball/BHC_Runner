/// scr_profiles_set_active(profile_id)
function scr_profiles_set_active(_profile_id)
{
    if (!variable_global_exists("profiles_data") || !is_struct(global.profiles_data)) return false;
    if (!variable_struct_exists(global.profiles_data, "profiles") || !is_array(global.profiles_data.profiles)) return false;

    for (var i = 0; i < array_length(global.profiles_data.profiles); i++) {
        var p = global.profiles_data.profiles[i];
        if (is_struct(p) && variable_struct_exists(p, "id") && p.id == _profile_id) {
            global.profiles_data.active_profile_id = _profile_id;
            p.updated_at = current_time;
            global.profiles_data.profiles[i] = p;
            return true;
        }
    }
    return false;
}
