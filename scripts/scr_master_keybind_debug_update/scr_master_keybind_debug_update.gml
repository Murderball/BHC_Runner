function scr_master_keybind_debug_update()
{
    if (!variable_global_exists("DEBUG_KEYBINDS") || !global.DEBUG_KEYBINDS) return;

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
        }
    }
}
