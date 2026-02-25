/// scr_profiles_get_save_root()
function scr_profiles_get_save_root()
{
    // Use a cached global to avoid repeated resolution
    if (variable_global_exists("profiles_cached_save_root") && is_string(global.profiles_cached_save_root)) {
        return global.profiles_cached_save_root;
    }

    // IMPORTANT: do not use any user-defined identifier named save_directory anywhere in the project
    // This reads the builtin save root as provided by GameMaker.
    var root = save_directory;

    // Normalize to string
    root = string(root);

    global.profiles_cached_save_root = root;
    return root;
}
