/// scr_story_unlock_level(level_key)
function scr_story_unlock_level(_level_key)
{
    if (!is_string(_level_key)) return false;

    var level_key = string_trim(_level_key);
    if (level_key == "") return false;

    if (script_exists(scr_profiles_boot)) scr_profiles_boot();

    var profile = script_exists(scr_profiles_get_active) ? scr_profiles_get_active() : undefined;
    if (!is_struct(profile)) return false;

    if (!variable_struct_exists(profile, "story") || !is_struct(profile.story)) profile.story = {};
    if (!variable_struct_exists(profile.story, "unlocked_level_keys") || !is_array(profile.story.unlocked_level_keys)) {
        profile.story.unlocked_level_keys = [];
    }

    var keys = profile.story.unlocked_level_keys;
    for (var i = 0; i < array_length(keys); i++) {
        if (string(keys[i]) == level_key) return true;
    }

    array_push(keys, level_key);
    profile.story.unlocked_level_keys = keys;
    profile.updated_at = current_time;

    if (variable_global_exists("profiles_data") && is_struct(global.profiles_data) && is_array(global.profiles_data.profiles)) {
        for (var pi = 0; pi < array_length(global.profiles_data.profiles); pi++) {
            var profile_item = global.profiles_data.profiles[pi];
            if (is_struct(profile_item) && variable_struct_exists(profile_item, "id") && profile_item.id == profile.id) {
                global.profiles_data.profiles[pi] = profile;
                break;
            }
        }
    }

    if (script_exists(scr_profiles_save)) scr_profiles_save();
    return true;
}
