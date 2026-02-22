function scr_master_keybind_debug_update()
{
    if (!variable_global_exists("DEBUG_KEYBINDS") || !global.DEBUG_KEYBINDS) return;

    if (keyboard_check_pressed(vk_f6))
    {
        if (keyboard_check(vk_shift))
        {
            scr_return_from_side_room();
        }
        else
        {
            scr_request_room_transition("rm_miniboss_1", { reason: "debug_f6" });
        }
    }

    if (keyboard_check_pressed(vk_f7))
    {
        scr_countdown_begin("debug");
    }

    if (keyboard_check_pressed(vk_f8))
    {
        if (!global.GAME_PAUSED)
        {
            global.GAME_PAUSED = true;
            if (variable_global_exists("song_handle") && global.song_handle >= 0) audio_pause_sound(global.song_handle);
            if (variable_global_exists("story_npc_handle") && global.story_npc_handle >= 0) audio_pause_sound(global.story_npc_handle);
            if (script_exists(scr_song_time)) global.pause_song_time = scr_song_time();
        }
        else
        {
            global.GAME_PAUSED = false;
            if (variable_global_exists("song_handle") && global.song_handle >= 0) audio_resume_sound(global.song_handle);
            if (variable_global_exists("story_npc_handle") && global.story_npc_handle >= 0) audio_resume_sound(global.story_npc_handle);
            scr_countdown_begin("unpause");
        }
    }

    if (keyboard_check_pressed(vk_f9))
    {
        var _router = variable_global_exists("STORY_ROUTER") ? json_stringify(global.STORY_ROUTER) : "{}";
        var _return = variable_global_exists("STORY_RETURN") ? json_stringify(global.STORY_RETURN) : "{}";
        show_debug_message("[debug:f9] router=" + _router);
        show_debug_message("[debug:f9] return=" + _return);
        show_debug_message("[debug:f9] countdown active=" + string(global.COUNTDOWN_ACTIVE)
            + " t=" + string(global.COUNTDOWN_TIMER_S)
            + " reason=" + string(global.COUNTDOWN_REASON));
    }
}
