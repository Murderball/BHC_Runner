/// scr_set_difficulty_song(diff, reason)
/// Swaps the currently selected main song based on difficulty.
/// If song is playing, restarts new song at the same time (keeps pause state too).
function scr_set_difficulty_song(_diff, _reason)
{
    // Never override boss music
    if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss") return;

    var d = string_lower(string(_diff));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    // --- determine level ---
    var lk = "level03";
    if (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)) lk = global.LEVEL_KEY;

    // --- ALWAYS rebuild mapping by level using snd_song_<level>_<difficulty> ---
    var level_index = 3;
    if (string_length(lk) >= 6) {
        level_index = clamp(real(string_copy(lk, 6, string_length(lk) - 5)), 1, 6);
    }

    global.DIFF_SONG_SOUND = {
        easy   : scr_level_song_sound(level_index, "easy"),
        normal : scr_level_song_sound(level_index, "normal"),
        hard   : scr_level_song_sound(level_index, "hard")
    };

    var new_snd = global.DIFF_SONG_SOUND[$ d];

    // Failsafe
    if (is_undefined(new_snd) || new_snd == -1)
    {
        new_snd = scr_level_song_sound(level_index, "normal");
    }

    // No-op if already selected
    if (variable_global_exists("song_sound") && global.song_sound == new_snd) return;

    var had_handle = (variable_global_exists("song_handle") && global.song_handle >= 0);
    var was_playing_flag = (variable_global_exists("song_playing") && global.song_playing);
    var was_paused = (had_handle && was_playing_flag && !audio_is_playing(global.song_handle));

    // Capture current timeline time (your engine’s authoritative time)
    var t_now = 0.0;
    if (script_exists(scr_song_time)) {
        t_now = scr_song_time();
    } else if (variable_global_exists("editor_time")) {
        t_now = global.editor_time;
    }

    // Select the new song
    global.song_sound = new_snd;

    // If nothing is playing yet, we're done
    if (!had_handle || !was_playing_flag) {
        show_debug_message("[SONG] selected " + d + " (idle) (" + string(_reason) + ") level=" + string(lk));
        return;
    }

    // Swap the playing handle, but keep time alignment
    audio_stop_sound(global.song_handle);
    global.song_handle = -1;

    global.song_handle = audio_play_sound(global.song_sound, 1, false);
    global.song_playing = true;

    var off = (variable_global_exists("OFFSET")) ? global.OFFSET : 0.0;
    audio_sound_set_track_position(global.song_handle, t_now + off);

    // Preserve paused state
    if (was_paused) audio_pause_sound(global.song_handle);

    show_debug_message("[SONG] -> " + d + " @t=" + string(t_now) + " (" + string(_reason) + ") level=" + string(lk));
}
