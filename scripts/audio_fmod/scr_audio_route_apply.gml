function scr_audio_route_apply()
{
    if (!variable_global_exists("fmod_music_map") || !is_struct(global.fmod_music_map)) return false;

    var level_key = "";
    if (script_exists(scr_active_level_key)) level_key = string_lower(scr_active_level_key());
    if (level_key == "" && script_exists(scr_level_key_from_room)) level_key = string_lower(scr_level_key_from_room(room));

    var diff = "normal";
    if (variable_global_exists("DIFFICULTY")) diff = string_lower(string(global.DIFFICULTY));
    if (diff != "easy" && diff != "normal" && diff != "hard") diff = "normal";

    var is_pause = false;
    if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED) is_pause = true;
    if (variable_global_exists("STORY_PAUSED") && global.STORY_PAUSED) is_pause = true;
    scr_fmod_pause_loop_set(is_pause);

    var bank = "";
    var event_name = "";

    if (room == rm_menu) {
        bank = "Menu_Sounds";
        event_name = global.fmod_menu_map.menu;
    } else if (room == rm_upgrade) {
        bank = "Menu_Sounds";
        event_name = global.fmod_menu_map.upgrade;
    } else {
        var is_boss = (room == rm_boss_1 || room == rm_boss_3);
        if (level_key == "level01") {
            bank = "Level_1";
            event_name = is_boss ? global.fmod_music_map.level01.boss : global.fmod_music_map.level01[$ diff];
        } else if (level_key == "level03") {
            bank = "Level_3";
            event_name = is_boss ? global.fmod_music_map.level03.boss : global.fmod_music_map.level03[$ diff];
        }
    }

    var path = scr_fmod_event_path_build(bank, event_name);
    if (path == "") {
        scr_fmod_music_stop();
        return false;
    }

    if (!variable_global_exists("fmod_last_music_path")) global.fmod_last_music_path = "";
    if (global.fmod_last_music_path == path && is_real(global.fmod_music_event) && global.fmod_music_event >= 0) return true;

    global.fmod_last_music_path = path;
    return scr_fmod_music_play(path);
}
