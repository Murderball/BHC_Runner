
scr_fmod_update();
if (!variable_global_exists("audio_last_room")) global.audio_last_room = room;
if (global.audio_last_room != room) {
    global.audio_last_room = room;
    if (script_exists(scr_audio_route_apply)) scr_audio_route_apply();
}
/// obj_game : Begin Step
scr_boss_timeline_update();

// Editor
scr_editor_update();

// Input
scr_input_update();

// STORY PAUSES (must run after input, before autoplay/gameplay)
scr_story_pause_update();


scr_difficulty_update();


// Notes triggering (atk1/atk2/atk3/ult)
if (script_exists(scr_note_trigger_inputs_update)) {
    scr_note_trigger_inputs_update();
}


scr_chart_hot_reload_step();

// ---------------- PERF SPIKE DETECTOR ----------------
if (variable_global_exists("dbg_spike_on") && global.dbg_spike_on)
{
    var us = delta_time; // microseconds for last frame
    if (us >= global.dbg_spike_us)
    {
        var t = (script_exists(scr_song_time) ? scr_song_time() : -1);

        global.dbg_last_spike_msg =
            "SPIKE " + string(us/1000) + "ms @t=" + string_format(t, 2, 3)
            + " | chart_load_t=" + string_format(global.dbg_last_chart_load_t,2,3)
            + " diff_apply_t=" + string_format(global.dbg_last_diff_apply_t,2,3)
            + " chunk_refresh_t=" + string_format(global.dbg_last_chunk_refresh_t,2,3)
            + " bg_repaint_t=" + string_format(global.dbg_last_bg_repaint_t,2,3);

        show_debug_message(global.dbg_last_spike_msg);
    }
}
