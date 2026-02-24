/// scr_set_playhead_time(t_s)
/// Jump playhead to an absolute time in seconds.
/// Updates editor_time / transport, forces chunk refresh, and seeks audio if playing.

function scr_set_playhead_time(t_s)
{
    if (is_undefined(t_s)) return;

    var t = max(0.0, real(t_s));
    if (variable_global_exists("SONG_LEN_S")) t = min(t, global.SONG_LEN_S);

    // ----------------------------
    // AUTHORITATIVE PLAYHEAD VARS
    // ----------------------------
    // Editor timeline base time (chart_time() derives from this)
    global.editor_time = t;

    // If you use a transport var anywhere else, keep it aligned too
    if (variable_global_exists("transport_time_s")) global.transport_time_s = t;

    // ----------------------------
    // Force chunk refresh after a jump
    // ----------------------------
    global.force_chunk_refresh = true;

    // ----------------------------
    // Best-effort audio seek (only when NOT in editor)
    // ----------------------------
    if (!global.editor_on) {
        if (variable_global_exists("song_handle") && global.song_handle >= 0 && audio_is_playing(global.song_handle)) {
            audio_sound_set_track_position(global.song_handle, t);
        }
    }
	
	// Keep story events aligned with seeks (prevents early markers firing after jumps)
	scr_story_seek_time(t);

    // ----------------------------
    // Re-arm autoplay after jumps
    // ----------------------------
    if (variable_global_exists("AUTO_HIT")) {
        global.auto_last_jump_t = -999999;
        global.auto_last_duck_t = -999999;
        global.auto_last_atk1_t = -999999;
        global.auto_last_atk2_t = -999999;
        global.auto_last_atk3_t = -999999;
        global.auto_prev_time_s = t;

        global.note_last_jump_t = -999999;
        global.note_last_duck_t = -999999;
        global.note_last_atk1_t = -999999;
        global.note_last_atk2_t = -999999;
        global.note_last_atk3_t = -999999;
        global.note_last_ult_t = -999999;
    }
}
