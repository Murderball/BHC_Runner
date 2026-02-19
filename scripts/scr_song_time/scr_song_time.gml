function scr_song_time()
{
    // Editor-controlled time (base timeline)
    if (variable_global_exists("editor_on") && global.editor_on) {
        if (variable_global_exists("editor_time") && !is_undefined(global.editor_time)) return global.editor_time;
        return 0.0;
    }

    // ----------------------------
    // HARD PAUSE: freeze time
    // ----------------------------
    if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED) {
        if (variable_global_exists("pause_song_time") && !is_undefined(global.pause_song_time)) {
            return global.pause_song_time;
        }
        return 0.0;
    }

    // Song not playing yet
    if (!variable_global_exists("song_playing") || !global.song_playing) return 0.0;
    if (!variable_global_exists("song_handle") || global.song_handle < 0) return 0.0;

    var t = audio_sound_get_track_position(global.song_handle);
    if (is_undefined(t)) t = 0.0;

    var off = 0.0;
    if (variable_global_exists("OFFSET") && !is_undefined(global.OFFSET)) off = global.OFFSET;

    t -= off;
    if (t < 0) t = 0;

    return t;
}
