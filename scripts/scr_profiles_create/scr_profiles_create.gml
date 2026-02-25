/// scr_profiles_create(name) -> string id
function scr_profiles_create(_name)
{
    if (!variable_global_exists("profiles_data") || !is_struct(global.profiles_data)) return "";
    if (!variable_struct_exists(global.profiles_data, "profiles") || !is_array(global.profiles_data.profiles)) global.profiles_data.profiles = [];

    var _nm = string(_name);
    if (string_length(_nm) <= 0) _nm = "Player " + string(array_length(global.profiles_data.profiles) + 1);

    var _id = "profile_" + string(current_time) + "_" + string(irandom(999999));
    var _profile = {
        id: _id,
        name: _nm,
        created_at: current_time,
        updated_at: current_time,
        arcade: { leaderboards: {} },
        story: { unlocked_level_keys: [], last_level_key: "", completed: {} },
        skills: { points_total: 0, points_spent: 0, nodes: {} }
    };

    if (script_exists(scr_story_default_unlocks)) _profile = scr_story_default_unlocks(_profile);
    array_push(global.profiles_data.profiles, _profile);
    global.profiles_data.active_profile_id = _id;

    if (script_exists(scr_story_unlock_level)) {
        scr_story_unlock_level("rm_level01");
        scr_story_unlock_level("level01");
    }

    return _id;
}
