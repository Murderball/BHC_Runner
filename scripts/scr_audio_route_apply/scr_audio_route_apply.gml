function scr_audio_route_apply()
{
    var bank = "";
    var event_name = "";

    var level_key = "";
    if (script_exists(scr_active_level_key)) level_key = string_lower(string(scr_active_level_key()));

    if (level_key == "") {
        if (room == rm_level01 || room == rm_boss_1) level_key = "level01";
        else if (room == rm_level03 || room == rm_boss_3) level_key = "level03";
    }

    var diff = "normal";
    if (variable_global_exists("difficulty")) diff = string_lower(string(global.difficulty));
    else if (variable_global_exists("DIFFICULTY")) diff = string_lower(string(global.DIFFICULTY));
    if (diff != "easy" && diff != "normal" && diff != "hard") diff = "normal";

    var is_boss = (room == rm_boss_1 || room == rm_boss_3);

    if (room == rm_menu) {
        bank = "Menu_Sounds";
        event_name = "Start_Menu";
    } else if (room == rm_upgrade) {
        bank = "Menu_Sounds";
        event_name = "Upgrade_Room";
    } else if (level_key == "level01") {
        bank = "Level_1";
        if (is_boss) event_name = "Level 1.4 -Hunger (BOSS)";
        else if (diff == "easy") event_name = "Level 1.1-Voice of Reason (Easy)";
        else if (diff == "hard") event_name = "Level 1.3 - Voice of Reason (Hard)";
        else event_name = "Level 1.2 - Voice of Reason (Normal)";
    } else if (level_key == "level03") {
        bank = "Level_3";
        if (is_boss) event_name = "Level 3.4 - Faceless(BOSS)";
        else if (diff == "easy") event_name = "Level 3.1 - Bringer of Rain (Easy)";
        else if (diff == "hard") event_name = "Level 3.3 - Bringer of Rain (Hard)";
        else event_name = "Level 3.2 - Bringer of Rain (Normal)";
    }

    if (bank == "" || event_name == "") {
        return false;
    }

    var path = scr_fmod_event_path_build(bank, event_name);
    var route_key = string(room) + "|" + bank + "|" + event_name + "|" + diff + "|" + string(is_boss);

    if (!variable_global_exists("fmod_route_key")) global.fmod_route_key = "";
    if (global.fmod_route_key == route_key) return false;

    global.fmod_route_key = route_key;
    show_debug_message("[FMOD] ROUTE -> " + route_key + " path=" + path + " room=" + room_get_name(room) + " level=" + level_key + " diff=" + diff + " boss=" + string(is_boss ? 1 : 0));

    return scr_fmod_music_play(bank, event_name);
}
