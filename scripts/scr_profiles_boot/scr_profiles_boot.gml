/// scr_profiles_boot()
function scr_profiles_boot()
{
    if (!script_exists(scr_profiles_ensure_defaults)) return false;
    scr_profiles_ensure_defaults();

    if (!object_exists(obj_profile_manager)) return false;
    if (!instance_exists(obj_profile_manager)) {
        var _layer = layer_get_id("Instances");
        if (_layer != -1) instance_create_layer(0, 0, "Instances", obj_profile_manager);
        else instance_create_depth(0, 0, 0, obj_profile_manager);
    }

    if (!variable_global_exists("profiles_booted") || !global.profiles_booted) {
        if (script_exists(scr_profiles_load)) scr_profiles_load();
        global.profiles_booted = true;
    }

    return true;
}
