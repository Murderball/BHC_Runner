function scr_song_time()
{
    if (variable_global_exists("editor_on") && global.editor_on) {
        if (variable_global_exists("editor_time") && is_real(global.editor_time)) return global.editor_time;
        return 0.0;
    }

    var s = scr_song_state_ensure();
    if (!scr_song_is_valid_inst(s.inst)) return max(0.0, s.last_pos_s);

    var audio_pos_s = scr_song_get_pos_s();

    // Chart-time target used for drift correction (no per-step restart/seek).
    var chart_time_s = audio_pos_s;
    if (variable_global_exists("transport_time_s") && is_real(global.transport_time_s)) {
        chart_time_s = max(0.0, global.transport_time_s);
    }

    var drift = audio_pos_s - chart_time_s;
    var can_resync = !s.paused
        && !(variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED)
        && room != rm_menu
        && ((current_time - s.last_resync_ms) >= 500);

    if (can_resync && abs(drift) > 0.050) {
        var target = chart_time_s;
        if (variable_global_exists("OFFSET") && is_real(global.OFFSET)) target += global.OFFSET;
        target = max(0.0, target);

        audio_sound_set_track_position(s.inst, target);
        s.last_resync_ms = current_time;
        s.last_pos_s = chart_time_s;

        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] drift resync drift=" + string_format(drift, 1, 3)
                + " target=" + string_format(chart_time_s, 1, 3));
        }

        return chart_time_s;
    }

    return audio_pos_s;
}
