/// scr_profiles_ensure_defaults()
function scr_profiles_ensure_defaults()
{
    // Force builtin resolution even if some instance/global variable tries to shadow it
    var base_dir = string(save_directory);

    if (!variable_global_exists("profiles_file_dir") || !is_string(global.profiles_file_dir)) {
        global.profiles_file_dir = base_dir + "bhc_profiles/";
    }

    if (!variable_global_exists("profiles_file_path") || !is_string(global.profiles_file_path)) {
        global.profiles_file_path = global.profiles_file_dir + "profiles.json";
    }

    // Ensure directory exists
    if (!directory_exists(global.profiles_file_dir)) {
        directory_create(global.profiles_file_dir);
    }

    // Ensure root data struct exists
    if (!variable_global_exists("profiles_data") || !is_struct(global.profiles_data)) {
        global.profiles_data = {
            version : 1,
            active_profile_id : "",
            profiles : []
        };
    }

    // Ensure profiles array exists
    if (!variable_struct_exists(global.profiles_data, "profiles") || !is_array(global.profiles_data.profiles)) {
        global.profiles_data.profiles = [];
    }
}
