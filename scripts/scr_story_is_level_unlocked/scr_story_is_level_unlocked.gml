/// scr_story_is_level_unlocked(level_key) -> bool
function scr_story_is_level_unlocked(_level_key)
{
    var _key = string(_level_key);
    if (_key == "") return true;
    var p = script_exists(scr_profiles_get_active) ? scr_profiles_get_active() : undefined;
    if (!is_struct(p)) return true;

    var arr = p.story.unlocked_level_keys;
    for (var i = 0; i < array_length(arr); i++) {
        if (string(arr[i]) == _key) return true;
    }
    return false;
}
