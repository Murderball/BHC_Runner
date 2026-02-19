/// scr_story_pause_start(ev)
/// ev is a struct from global.story_events

function scr_story_pause_start(ev)
{
    if (global.STORY_PAUSED) return;

    global.STORY_PAUSED = true;
    global.story_state = "fade_out";
    global.story_timer = 0.0;
	
	    // --- NEW: set popup text immediately from marker/event ---
    global.story_choice_caption = "";
    if (is_struct(ev) && variable_struct_exists(ev, "caption")) {
        global.story_choice_caption = string(ev.caption);
    }

    // Preload choices (so UI is ready when we enter "choice")
    global.story_choice_options = [];
    if (is_struct(ev) && variable_struct_exists(ev, "choices") && is_array(ev.choices)) {
        global.story_choice_options = ev.choices;
    }
    global.story_choice_sel = 0;

	
    // Snapshot the current song time (used only for debug / safety)
    global.story_pause_song_t = scr_song_time();

    // Fade out + pause song cleanly
    global.story_song_was_playing = (global.song_handle >= 0) && global.song_playing;

    if (global.story_song_was_playing) {
        var ms = max(0, ev.fade_out_ms);
        audio_sound_gain(global.song_handle, 0.0, ms);
        global.story_timer = ms / 1000.0;
    } else {
        // If song isn't playing, skip fade logic
        global.story_timer = 0.0;
    }

    // Stop any prior NPC clip
    if (global.story_npc_handle >= 0) {
        audio_stop_sound(global.story_npc_handle);
        global.story_npc_handle = -1;
    }
}
