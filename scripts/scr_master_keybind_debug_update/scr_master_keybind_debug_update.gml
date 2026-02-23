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
            if (variable_global_exists("pending_song_start") && global.pending_song_start
                && script_exists(scr_song_play_from)
                && variable_global_exists("song_sound") && audio_exists(global.song_sound)) {
                var resume_t = (variable_global_exists("pause_song_time") && is_real(global.pause_song_time)) ? max(0.0, global.pause_song_time) : 0.0;
                scr_song_play_from(global.song_sound, resume_t);
                global.pending_song_start = false;
            } else if (variable_global_exists("song_handle") && global.song_handle >= 0) {
                audio_resume_sound(global.song_handle);
            }
            if (variable_global_exists("story_npc_handle") && global.story_npc_handle >= 0) audio_resume_sound(global.story_npc_handle);
        }
    }
}
