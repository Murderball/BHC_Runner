/// scr_story_seek_time(t_s)
/// Marks story events before t_s as done so they don't trigger when starting mid-song.
/// Also resets any active story pause state.

function scr_story_seek_time(t_s)
{
    if (!is_array(global.story_events)) return;

    var t = max(0.0, real(t_s));

    // Kill any active story pause state
    global.STORY_PAUSED = false;
    global.story_state = "idle";
    global.story_timer = 0;

    if (variable_global_exists("story_choice_active")) global.story_choice_active = false;

    if (variable_global_exists("story_npc_handle") && global.story_npc_handle >= 0) {
        audio_stop_sound(global.story_npc_handle);
        global.story_npc_handle = -1;
    }

    // Make sure main song isn't left faded out
    if (global.song_handle >= 0) {
        audio_sound_gain(global.song_handle, 1.0, 0);
        if (!audio_is_playing(global.song_handle) && global.song_playing) {
            // If you paused it previously, resume
            audio_resume_sound(global.song_handle);
        }
    }

    // Mark events earlier than the seek time as already done
    var n = array_length(global.story_events);
    var next_i = -1;

    for (var i = 0; i < n; i++) {
        var ev = global.story_events[i];

        if (!is_struct(ev)) continue;

        ev.done = (ev.t < t);      // key line: skip past events
        global.story_events[i] = ev;

        if (next_i < 0 && !ev.done) next_i = i;
    }

    global.story_idx = max(0, next_i);
}
