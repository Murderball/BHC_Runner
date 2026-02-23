function scr_song_state_ensure()
{
    if (!variable_global_exists("song_state") || !is_struct(global.song_state)) {
        global.song_state = {
            sound_asset      : -1,
            inst             : -1,
            started_at_time_s: 0.0,
            chart_offset_s   : 0.0,
            paused           : false,
            last_seek_time_s : -1.0,
            last_seek_real_ms: -1000000,
            last_known_pos_s : 0.0,
            started_real_ms  : current_time,
            last_log_ms      : -1000000
        };
    }
if (global.AUDIO_DEBUG_LOG) {
    var a0 = (argument_count >= 1) ? argument[0] : -999;
    var a1 = (argument_count >= 2) ? argument[1] : -999;
    show_debug_message("[AUDIO] play_from argc=" + string(argument_count)
        + " a0=" + string(a0) + " exists(a0)=" + string(audio_exists(a0))
        + " a1=" + string(a1));
}
    if (!variable_global_exists("song_handle"))  global.song_handle = -1;
    if (!variable_global_exists("song_sound"))   global.song_sound = -1;
    if (!variable_global_exists("song_playing")) global.song_playing = false;
    if (!variable_global_exists("AUDIO_DEBUG_LOG")) global.AUDIO_DEBUG_LOG = false;
}

function scr_song_is_valid_asset(_sound_asset)
{
    return is_real(_sound_asset) && !is_nan(_sound_asset) && real(_sound_asset) >= 0;
}

function scr_song_is_valid_inst(_inst)
{
    return is_real(_inst) && !is_nan(_inst) && real(_inst) >= 0;
}

function scr_song_get_pos_s()
{
    scr_song_state_ensure();

    var st = global.song_state;
    if (!scr_song_is_valid_inst(st.inst)) return st.last_known_pos_s;

    var pos = audio_sound_get_track_position(st.inst);
    if (!is_real(pos) || is_nan(pos)) pos = st.last_known_pos_s;

    var off = st.chart_offset_s;
    if (variable_global_exists("CHART_TIME_OFFSET_S") && is_real(global.CHART_TIME_OFFSET_S)) {
        off = real(global.CHART_TIME_OFFSET_S);
    } else if (variable_global_exists("OFFSET") && is_real(global.OFFSET)) {
        off = real(global.OFFSET);
    }
    pos -= off;
    if (pos < 0) pos = 0;

    st.last_known_pos_s = pos;

    if (global.AUDIO_DEBUG_LOG && (current_time - st.last_log_ms) >= 1000) {
        st.last_log_ms = current_time;
        show_debug_message("[AUDIO] pos=" + string_format(pos, 1, 3)
            + " inst=" + string(st.inst)
            + " snd=" + string(st.sound_asset));
    }

    return pos;
}

function scr_song_debug_draw(_x, _y)
{
    scr_song_state_ensure();

    var st = global.song_state;
    var px = _x;
    var py = _y;

    var diff = "normal";
    if (variable_global_exists("DIFFICULTY")) diff = string(global.DIFFICULTY);

    var snd_name = "<none>";
    if (scr_song_is_valid_asset(st.sound_asset)) snd_name = asset_get_name(st.sound_asset);

    var audio_pos = scr_song_get_pos_s();
    var chart_pos = (script_exists(scr_chart_time)) ? scr_chart_time() : 0.0;
    var drift = audio_pos - chart_pos;

    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_text(px, py, "Song Debug");
    draw_text(px, py + 16, "diff: " + diff);
    draw_text(px, py + 32, "asset: " + snd_name + " [" + string(st.sound_asset) + "]");
    draw_text(px, py + 48, "inst: " + string(st.inst) + " playing=" + string(global.song_playing));
    draw_text(px, py + 64, "audio_pos: " + string_format(audio_pos, 1, 3));
    draw_text(px, py + 80, "chart_time: " + string_format(chart_pos, 1, 3));
    draw_text(px, py + 96, "drift: " + string_format(drift, 1, 3));

    if (variable_global_exists("song_no_music_level") && global.song_no_music_level) {
        draw_text(px, py + 112, "No music for this level");
    }
}

/// scr_song_play_from(time_sec)
/// Also accepts scr_song_play_from(sound_asset) and scr_song_play_from(sound_asset, time_sec).
function scr_song_play_from(time_sec) {
    scr_song_state_ensure();

    if (!variable_global_exists("__audio_warned") || !is_struct(global.__audio_warned)) {
        global.__audio_warned = {};
    }

    function _audio_warn_once(_key, _msg) {
        if (!variable_struct_exists(global.__audio_warned, _key)) {
            global.__audio_warned[$ _key] = true;
            show_debug_message(_msg);
        }
    }

    var st = global.song_state;

    if (!variable_global_exists("_song_play_from_window_start_ms")) global._song_play_from_window_start_ms = current_time;
    if (!variable_global_exists("_song_play_from_window_calls")) global._song_play_from_window_calls = 0;
    if (!variable_global_exists("_song_play_from_last_reset_call_ms")) global._song_play_from_last_reset_call_ms = -1000000;

    if ((current_time - global._song_play_from_window_start_ms) >= 1000) {
        if (global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] scr_song_play_from calls/sec=" + string(global._song_play_from_window_calls));
        }
        global._song_play_from_window_start_ms = current_time;
        global._song_play_from_window_calls = 0;
    }
    global._song_play_from_window_calls += 1;

    var snd_asset = (scr_song_is_valid_asset(st.sound_asset)) ? st.sound_asset : global.song_sound;
    var start_time = 0.0;
    var arg0_is_audio_asset = false;

    if (argument_count <= 0) {
        if ((current_time - global._song_play_from_last_reset_call_ms) < 120) {
            if (global.AUDIO_DEBUG_LOG) {
                show_debug_message("[AUDIO] scr_song_play_from argc=0 debounced");
            }
            return false;
        }
        global._song_play_from_last_reset_call_ms = current_time;

        if (!audio_exists(snd_asset)) {
            _audio_warn_once(
                "scr_song_play_from_noargs_no_current",
                "[AUDIO] scr_song_play_from argc=0 ignored: no valid current sound to restart"
            );
            return false;
        }

        start_time = 0.0;
    } else if (argument_count == 1) {
        arg0_is_audio_asset = audio_exists(argument[0]);
        if (arg0_is_audio_asset) {
            snd_asset = argument[0];
            start_time = 0.0;
        } else {
            snd_asset = (scr_song_is_valid_asset(st.sound_asset)) ? st.sound_asset : global.song_sound;
            start_time = argument[0];
        }
    } else {
        snd_asset = argument[0];
        start_time = argument[1];
    }

    snd_asset = real(snd_asset);
    if (!is_real(start_time) || is_nan(start_time)) start_time = 0.0;
    start_time = max(0.0, start_time);

    var off = 0.0;
    if (variable_global_exists("CHART_TIME_OFFSET_S") && is_real(global.CHART_TIME_OFFSET_S)) {
        off = real(global.CHART_TIME_OFFSET_S);
    } else if (variable_global_exists("OFFSET") && is_real(global.OFFSET)) {
        off = real(global.OFFSET);
    }

    if (global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] scr_song_play_from argc=" + string(argument_count)
            + " resolved_snd=" + string(snd_asset)
            + " start_s=" + string_format(start_time, 1, 3)
            + " arg0_audio_exists=" + string(arg0_is_audio_asset));
    }

    if (!audio_exists(snd_asset)) {
        var fallback_snd = -1;
        if (audio_exists(st.sound_asset)) fallback_snd = st.sound_asset;
        else if (audio_exists(global.song_sound)) fallback_snd = global.song_sound;

        if (audio_exists(fallback_snd)) {
            _audio_warn_once(
                "scr_song_play_from_keep_current_invalid_req_" + string(snd_asset),
                "[AUDIO] scr_song_play_from requested invalid sound " + string(snd_asset)
                + "; keeping current sound " + string(fallback_snd) + " inst=" + string(st.inst)
            );
            return false;
        }

        _audio_warn_once(
            "scr_song_play_from_invalid_sound_" + string(snd_asset),
            "[AUDIO] scr_song_play_from ignored invalid sound asset index: " + string(snd_asset)
        );
        return false;
    }

    if (scr_song_is_valid_inst(st.inst)) {
        audio_stop_sound(st.inst);
    }

    if (script_exists(scr_story_seek_time)) {
        scr_story_seek_time(start_time);
    }

    var inst = audio_play_sound(snd_asset, 1, false);
    if (global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] scr_song_play_from play_sound snd=" + string(snd_asset)
            + " inst=" + string(inst)
            + " audio_exists=" + string(audio_exists(snd_asset)));
    }

    if (!scr_song_is_valid_inst(inst)) {
        _audio_warn_once(
            "scr_song_play_from_play_failed_" + string(snd_asset),
            "[AUDIO] scr_song_play_from failed to start sound asset index: " + string(snd_asset)
        );

        st.inst = -1;
        global.song_handle = -1;
        global.song_playing = false;
        return false;
    }

    audio_sound_set_track_position(inst, start_time + off);

    st.sound_asset = snd_asset;
    st.inst = inst;
    st.started_at_time_s = start_time;
    st.chart_offset_s = off;
    st.paused = false;
    st.last_seek_time_s = start_time;
    st.last_seek_real_ms = current_time;
    st.last_known_pos_s = start_time;
    st.started_real_ms = current_time;

    global.song_sound = snd_asset;
    global.song_handle = inst;
    global.song_playing = true;

    if (global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] start snd=" + asset_get_name(snd_asset)
            + "[" + string(snd_asset) + "]"
            + " inst=" + string(inst)
            + " seek=" + string_format(start_time + off, 1, 3)
            + " reason=play_from");
    }

    return true;
}
