/// scr_story_default_unlocks(profile_struct)
function scr_story_default_unlocks(_profile)
{
    if (!is_struct(_profile)) return _profile;
    if (!variable_struct_exists(_profile, "story") || !is_struct(_profile.story)) _profile.story = { unlocked_level_keys: [], last_level_key: "", completed: {} };
    if (!variable_struct_exists(_profile.story, "unlocked_level_keys") || !is_array(_profile.story.unlocked_level_keys)) _profile.story.unlocked_level_keys = [];

    var _defaults = ["rm_level01", "level01"];
    for (var i = 0; i < array_length(_defaults); i++) {
        var _k = _defaults[i];
        var _found = false;
        for (var j = 0; j < array_length(_profile.story.unlocked_level_keys); j++) {
            if (string(_profile.story.unlocked_level_keys[j]) == _k) { _found = true; break; }
        }
        if (!_found) array_push(_profile.story.unlocked_level_keys, _k);
    }
    return _profile;
}
