/// scr_profiles_get_active() -> struct|undefined
function scr_profiles_get_active()
{
    if (!variable_global_exists("profiles_data") || !is_struct(global.profiles_data)) return undefined;
    if (!variable_struct_exists(global.profiles_data, "profiles") || !is_array(global.profiles_data.profiles)) return undefined;
    for (var i = 0; i < array_length(global.profiles_data.profiles); i++) {
        var p = global.profiles_data.profiles[i];
        if (is_struct(p) && variable_struct_exists(p, "id") && p.id == global.profiles_data.active_profile_id) return p;
    }
    return undefined;
}
