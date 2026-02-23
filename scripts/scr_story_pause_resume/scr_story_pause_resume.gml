function scr_story_pause_resume(ev)
{
    scr_fmod_pause_loop_set(false);
    global.story_npc_handle = -1;

    if (global.story_song_was_playing) {
        global.story_state = "fade_in";
        global.story_timer = max(0, ev.fade_in_ms) / 1000.0;
    } else {
        global.story_state = "idle";
        global.STORY_PAUSED = false;
    }

    if (script_exists(scr_audio_route_apply)) scr_audio_route_apply();
}
