/// scr_story_pause_resume(ev)
/// Resumes main song with fade-in.

function scr_story_pause_resume(ev)
{
    // Stop npc handle (if any)
    if (global.story_npc_handle >= 0) {
        audio_stop_sound(global.story_npc_handle);
        global.story_npc_handle = -1;
    }

    // Resume + fade in the main song
    if (global.story_song_was_playing && global.song_handle >= 0) {
        audio_resume_sound(global.song_handle);

        var ms = max(0, ev.fade_in_ms);
        audio_sound_gain(global.song_handle, 1.0, ms);

        global.story_state = "fade_in";
        global.story_timer = ms / 1000.0;
    } else {
        // Nothing to resume
        global.story_state = "idle";
        global.STORY_PAUSED = false;
    }
}
