function scr_song_time()
{
    if (variable_global_exists("editor_on") && global.editor_on) {
        if (variable_global_exists("editor_time") && !is_undefined(global.editor_time)) return global.editor_time;
        return 0.0;
    }

    if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED) {
        if (variable_global_exists("pause_song_time") && !is_undefined(global.pause_song_time)) {
            return global.pause_song_time;
        }
        return 0.0;
    }

    if (!variable_global_exists("song_playing") || !global.song_playing) return 0.0;
    if (!script_exists(scr_song_state_ensure)) return 0.0;

    scr_song_state_ensure();
    var st = global.song_state;

    if (!scr_song_is_valid_inst(st.inst)) return max(0.0, st.last_known_pos_s);

    var t = scr_song_get_pos_s();

    // Drift correction: only when big drift AND rate-limited.
    var expect = st.started_at_time_s + max(0.0, (current_time - st.started_real_ms) / 1000.0);
    var drift = t - expect;

    if (abs(drift) > 0.050 && (current_time - st.last_seek_real_ms) >= 500) {
        var off = st.chart_offset_s;
        var target = max(0.0, expect + off);
        audio_sound_set_track_position(st.inst, target);

        st.last_seek_time_s = expect;
        st.last_seek_real_ms = current_time;
        st.last_known_pos_s = expect;

        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] drift-correct seek inst=" + string(st.inst)
                + " drift=" + string_format(drift, 1, 3)
                + " target=" + string_format(expect, 1, 3));
        }

        t = expect;
    }

    return max(0.0, t);
}
