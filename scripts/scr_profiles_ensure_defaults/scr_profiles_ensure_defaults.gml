/// scr_profiles_ensure_defaults()
function scr_profiles_ensure_defaults()
{
    if (!variable_global_exists("profiles_version")) global.profiles_version = 1;
    if (!variable_global_exists("profiles_file_dir")) global.profiles_file_dir = save_directory + "bhc_profiles/";
    if (!variable_global_exists("profiles_file_path")) global.profiles_file_path = global.profiles_file_dir + "profiles.json";

    if (!variable_global_exists("profiles_data") || !is_struct(global.profiles_data)) {
        global.profiles_data = { version: global.profiles_version, active_profile_id: "", profiles: [] };
    }

    if (!variable_struct_exists(global.profiles_data, "version")) global.profiles_data.version = global.profiles_version;
    if (!variable_struct_exists(global.profiles_data, "active_profile_id")) global.profiles_data.active_profile_id = "";
    if (!variable_struct_exists(global.profiles_data, "profiles") || !is_array(global.profiles_data.profiles)) global.profiles_data.profiles = [];

    var _profiles = global.profiles_data.profiles;
    for (var i = 0; i < array_length(_profiles); i++) {
        var p = _profiles[i];
        if (!is_struct(p)) p = {};

        if (!variable_struct_exists(p, "id") || string(p.id) == "") p.id = "profile_" + string(i + 1);
        if (!variable_struct_exists(p, "name") || string(p.name) == "") p.name = "Player " + string(i + 1);
        if (!variable_struct_exists(p, "created_at")) p.created_at = current_time;
        if (!variable_struct_exists(p, "updated_at")) p.updated_at = current_time;

        if (!variable_struct_exists(p, "arcade") || !is_struct(p.arcade)) p.arcade = {};
        if (!variable_struct_exists(p.arcade, "leaderboards") || !is_struct(p.arcade.leaderboards)) p.arcade.leaderboards = {};

        if (!variable_struct_exists(p, "story") || !is_struct(p.story)) p.story = {};
        if (!variable_struct_exists(p.story, "unlocked_level_keys") || !is_array(p.story.unlocked_level_keys)) p.story.unlocked_level_keys = [];
        if (!variable_struct_exists(p.story, "last_level_key")) p.story.last_level_key = "";
        if (!variable_struct_exists(p.story, "completed") || !is_struct(p.story.completed)) p.story.completed = {};
        if (script_exists(scr_story_default_unlocks)) p = scr_story_default_unlocks(p);

        if (!variable_struct_exists(p, "skills") || !is_struct(p.skills)) p.skills = {};
        if (!variable_struct_exists(p.skills, "points_total")) p.skills.points_total = 0;
        if (!variable_struct_exists(p.skills, "points_spent")) p.skills.points_spent = 0;
        if (!variable_struct_exists(p.skills, "nodes") || !is_struct(p.skills.nodes)) p.skills.nodes = {};

        _profiles[i] = p;
    }

    global.profiles_data.profiles = _profiles;

    if (array_length(global.profiles_data.profiles) <= 0 && script_exists(scr_profiles_create)) {
        scr_profiles_create("Player 1");
    }

    if (array_length(global.profiles_data.profiles) > 0) {
        var _active_ok = false;
        for (var j = 0; j < array_length(global.profiles_data.profiles); j++) {
            if (global.profiles_data.profiles[j].id == global.profiles_data.active_profile_id) { _active_ok = true; break; }
        }
        if (!_active_ok) global.profiles_data.active_profile_id = global.profiles_data.profiles[0].id;
    }

    if (!variable_global_exists("profile_view_level_key")) global.profile_view_level_key = "rm_level01";
    if (!variable_global_exists("profile_view_difficulty")) global.profile_view_difficulty = "normal";
    if (!variable_global_exists("profile_panel_focus")) global.profile_panel_focus = false;
    if (!variable_global_exists("profile_ui_active")) global.profile_ui_active = false;
    if (!variable_global_exists("profile_ui_mode")) global.profile_ui_mode = "";
    if (!variable_global_exists("profile_ui_text")) global.profile_ui_text = "";
    if (!variable_global_exists("profile_ui_prev_keyboard_string")) global.profile_ui_prev_keyboard_string = "";
}
