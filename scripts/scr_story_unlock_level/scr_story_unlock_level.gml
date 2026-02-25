/// scr_story_unlock_level(level_key)
function scr_story_unlock_level(_level_key)
{
    var _key = string(_level_key);
    if (_key == "") return false;

    if (!variable_global_exists("profiles_data") || !is_struct(global.profiles_data) || !is_array(global.profiles_data.profiles)) return false;

    for (var pi = 0; pi < array_length(global.profiles_data.profiles); pi++) {
        var p = global.profiles_data.profiles[pi];
        if (!is_struct(p) || p.id != global.profiles_data.active_profile_id) continue;

        var arr = p.story.unlocked_level_keys;
        var found = false;
        for (var i = 0; i < array_length(arr); i++) if (string(arr[i]) == _key) { found = true; break; }
        if (!found) {
            array_push(arr, _key);
            p.story.unlocked_level_keys = arr;
            p.updated_at = current_time;
            global.profiles_data.profiles[pi] = p;
            if (script_exists(scr_profiles_save)) scr_profiles_save();
        }
        return true;
    }
    return false;
}
