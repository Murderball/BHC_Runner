function scr_audio_route_apply()
{
    var paused_bool = false;
    if (variable_global_exists("paused")) paused_bool = global.paused;
    else paused_bool = (variable_global_exists("paused") && global.paused);

    scr_fmod_pause_loop_set(paused_bool);

    var bank = "";
    var event_name = "";

    if (room == rm_menu)
    {
        bank = "Menu_Sounds";
        event_name = "Start_Menu";
    }
    else if (room == rm_upgrade)
    {
        bank = "Menu_Sounds";
        event_name = "Upgrade_Room";
    }
    else
    {
        var diff = "normal";
        if (variable_global_exists("difficulty")) diff = string_lower(string(global.difficulty));
        else if (variable_global_exists("DIFFICULTY")) diff = string_lower(string(global.DIFFICULTY));

        if (diff != "easy" && diff != "normal" && diff != "hard") diff = "normal";

        var is_boss = (room == rm_boss_1 || room == rm_boss_3);

        if (room == rm_level01 || room == rm_boss_1)
        {
            bank = "Level_1";
            if (is_boss) event_name = "Level 1.4 -Hunger (BOSS)";
            else if (diff == "easy") event_name = "Level 1.1-Voice of Reason (Easy)";
            else if (diff == "hard") event_name = "Level 1.3 - Voice of Reason (Hard)";
            else event_name = "Level 1.2 - Voice of Reason (Normal)";
        }
        else if (room == rm_level03 || room == rm_boss_3)
        {
            bank = "Level_3";
            if (is_boss) event_name = "Level 3.4 - Faceless(BOSS)";
            else if (diff == "easy") event_name = "Level 3.1 - Bringer of Rain (Easy)";
            else if (diff == "hard") event_name = "Level 3.3 - Bringer of Rain (Hard)";
            else event_name = "Level 3.2 - Bringer of Rain (Normal)";
        }
    }

    var route_key = string(room) + "|" + bank + "|" + event_name + "|" + string(paused_bool);
    if (!variable_global_exists("fmod_last_route_key")) global.fmod_last_route_key = "";

    if (route_key == global.fmod_last_route_key) return false;

    global.fmod_last_route_key = route_key;

    if (bank == "" || event_name == "")
    {
        scr_fmod_music_stop();
        return false;
    }

    return scr_fmod_music_play(bank, event_name);
}
