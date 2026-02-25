/// scr_story_mark_completed(level_key)
function scr_story_mark_completed(_level_key)
{
    var _key = string(_level_key);
    if (_key == "") return false;

    var p = script_exists(scr_profiles_get_active) ? scr_profiles_get_active() : undefined;
    if (!is_struct(p)) return false;

    p.story.completed[$ _key] = true;
    p.story.last_level_key = _key;
    p.updated_at = current_time;

    for (var i = 0; i < array_length(global.profiles_data.profiles); i++) {
        if (global.profiles_data.profiles[i].id == p.id) {
            global.profiles_data.profiles[i] = p;
            break;
        }
    }

    if (script_exists(scr_profiles_save)) scr_profiles_save();
    return true;
}
