// ------------------------------------------------------------
// Song state + helpers (robust)
// ------------------------------------------------------------

function scr_song_state_ensure()
{
    // Ensure debug flag first (so later code can read it safely)
    if (!variable_global_exists("AUDIO_DEBUG_LOG")) global.AUDIO_DEBUG_LOG = false;

    if (!variable_global_exists("song_state") || !is_struct(global.song_state)) {
        global.song_state = {
            sound_asset       : -1,
            inst              : -1,
            started_at_time_s : 0.0,          // requested chart-time start (seconds)
            chart_offset_s    : 0.0,          // offset used when seeking (seconds)
            paused            : false,

            last_seek_time_s  : -1.0,
            last_seek_real_ms : -1000000,
            last_known_pos_s  : 0.0,

            started_real_ms   : current_time, // real clock at start (ms)
            last_raw_pos_s    : -1.0,         // last raw track pos (seconds)
            last_raw_ms       : -1000000,     // last time raw pos changed (ms)
            last_log_ms       : -1000000
        };
    }

    if (!variable_global_exists("song_handle"))  global.song_handle  = -1;
    if (!variable_global_exists("song_sound"))   global.song_sound   = -1;
    if (!variable_global_exists("song_playing")) global.song_playing = false;
}

function scr_song_is_valid_asset(_sound_asset)
{
    return is_real(_sound_asset) && !is_nan(_sound_asset) && real(_sound_asset) >= 0 && audio_exists(real(_sound_asset));
}

function scr_song_is_valid_inst(_inst)
{
    return is_real(_inst) && !is_nan(_inst) && real(_inst) >= 0;
}

function scr_song_asset_label(_sound_asset)
{
    return "snd#" + string(_sound_asset);
}

// Returns the best-known "song position" in seconds, in chart-time space (offset removed).
function scr_song_get_pos_s()
{
    scr_song_state_ensure();

    var st = global.song_state;

    // If we have no instance, return last known (doesn't jump)
    if (!scr_song_is_valid_inst(st.inst)) return st.last_known_pos_s;

    // Determine offset compat
    var off = st.chart_offset_s;
    if (variable_global_exists("CHART_TIME_OFFSET_S") && is_real(global.CHART_TIME_OFFSET_S)) off = real(global.CHART_TIME_OFFSET_S);
    else if (variable_global_exists("OFFSET") && is_real(global.OFFSET)) off = real(global.OFFSET);

    // Truth: is the instance actually playing?
    var is_playing = audio_sound_is_playing(st.inst);

    // Raw track position (may be 0/not supported on non-streamed sounds)
    var raw = audio_sound_get_track_position(st.inst);
    var raw_ok = is_real(raw) && !is_nan(raw);

    // Track whether raw is "moving"
    if (raw_ok) {
        if (st.last_raw_pos_s < 0) {
            st.last_raw_pos_s = raw;
            st.last_raw_ms = current_time;
        } else {
            // Consider "moved" if it changes by at least 5ms
            if (abs(raw - st.last_raw_pos_s) >= 0.005) {
                st.last_raw_pos_s = raw;
                st.last_raw_ms = current_time;
            }
        }
    }

    // Fallback clock: time since we started (real clock), plus started_at_time_s
    // This is what makes the game advance even if raw track pos is stuck at 0.
    var fallback_pos = st.started_at_time_s + max(0.0, (current_time - st.started_real_ms) / 1000.0);

    // Decide which position to trust:
    // - If not playing, don't advance; return last_known.
    // - If raw is valid AND has moved recently, trust raw.
    // - Otherwise trust fallback.
    var use_raw = false;
    if (is_playing && raw_ok) {
        // If raw has moved at least once in the last 250ms, we trust it.
        // If raw never moves (non-streamed), this will fall back.
        if ((current_time - st.last_raw_ms) <= 250) use_raw = true;
    }

    var pos = (use_raw) ? raw : fallback_pos;

    // Convert to chart-time space
    pos -= off;
    if (pos < 0) pos = 0;

    st.last_known_pos_s = pos;

    if (global.AUDIO_DEBUG_LOG && (current_time - st.last_log_ms) >= 1000) {
        st.last_log_ms = current_time;
        show_debug_message("[AUDIO] pos=" + string_format(pos, 1, 3)
            + " raw=" + (raw_ok ? string_format(raw,1,3) : "<bad>")
            + " use_raw=" + string(use_raw)
            + " playing=" + string(is_playing)
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
    if (scr_song_is_valid_asset(st.sound_asset)) snd_name = scr_song_asset_label(st.sound_asset);

    var inst_playing = (scr_song_is_valid_inst(st.inst)) ? audio_sound_is_playing(st.inst) : false;
    var raw = (scr_song_is_valid_inst(st.inst)) ? audio_sound_get_track_position(st.inst) : 0.0;

    var audio_pos = scr_song_get_pos_s();
    var chart_pos = (script_exists(scr_chart_time)) ? scr_chart_time() : 0.0;
    var drift = audio_pos - chart_pos;

    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_text(px, py, "Song Debug");
    draw_text(px, py + 16, "diff: " + diff);
    draw_text(px, py + 32, "asset: " + snd_name + " [" + string(st.sound_asset) + "]");
    draw_text(px, py + 48, "inst: " + string(st.inst) + " inst_playing=" + string(inst_playing));
    draw_text(px, py + 64, "song_playing flag: " + string(global.song_playing));
    draw_text(px, py + 80, "raw_track_pos: " + (is_real(raw) ? string_format(raw,1,3) : "<bad>"));
    draw_text(px, py + 96, "audio_pos: " + string_format(audio_pos, 1, 3));
    draw_text(px, py + 112, "chart_time: " + string_format(chart_pos, 1, 3));
    draw_text(px, py + 128, "drift: " + string_format(drift, 1, 3));
}


/// scr_song_play_from(time_sec)
/// Also accepts scr_song_play_from(sound_asset) and scr_song_play_from(sound_asset, time_sec).
function scr_song_play_from(time_sec)
{
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

    // calls/sec counter
    if (!variable_global_exists("_song_play_from_window_start_ms")) global._song_play_from_window_start_ms = current_time;
    if (!variable_global_exists("_song_play_from_window_calls")) global._song_play_from_window_calls = 0;
    if (!variable_global_exists("_song_play_from_last_reset_call_ms")) global._song_play_from_last_reset_call_ms = -1000000;

    if ((current_time - global._song_play_from_window_start_ms) >= 1000) {
        if (global.AUDIO_DEBUG_LOG) show_debug_message("[AUDIO] scr_song_play_from calls/sec=" + string(global._song_play_from_window_calls));
        global._song_play_from_window_start_ms = current_time;
        global._song_play_from_window_calls = 0;
    }
    global._song_play_from_window_calls += 1;

    // Resolve default sound
    var snd_asset = (scr_song_is_valid_asset(st.sound_asset)) ? st.sound_asset : global.song_sound;
    var start_time = 0.0;
    var arg0_is_audio_asset = false;

    // Parse arguments safely
    if (argument_count <= 0) {
        // Zero-arg call = bug in caller; never kill playback state.
        if ((current_time - global._song_play_from_last_reset_call_ms) < 120) {
            if (global.AUDIO_DEBUG_LOG) show_debug_message("[AUDIO] scr_song_play_from argc=0 debounced");
            return false;
        }
        global._song_play_from_last_reset_call_ms = current_time;

        if (!audio_exists(snd_asset)) {
            _audio_warn_once("scr_song_play_from_noargs_no_current",
                "[AUDIO] scr_song_play_from argc=0 ignored: no valid current sound");
            return false;
        }
        start_time = 0.0;
    }
    else if (argument_count == 1) {
        arg0_is_audio_asset = audio_exists(argument[0]);
        if (arg0_is_audio_asset) {
            snd_asset = argument[0];
            start_time = 0.0;
        } else {
            start_time = argument[0];
            snd_asset = (scr_song_is_valid_asset(st.sound_asset)) ? st.sound_asset : global.song_sound;
        }
    }
    else {
        snd_asset = argument[0];
        start_time = argument[1];
    }

    snd_asset = real(snd_asset);
    if (!is_real(start_time) || is_nan(start_time)) start_time = 0.0;
    start_time = max(0.0, start_time);

    // Offset compat
    var off = 0.0;
    if (variable_global_exists("CHART_TIME_OFFSET_S") && is_real(global.CHART_TIME_OFFSET_S)) off = real(global.CHART_TIME_OFFSET_S);
    else if (variable_global_exists("OFFSET") && is_real(global.OFFSET)) off = real(global.OFFSET);

    if (global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] play_from argc=" + string(argument_count)
            + " snd=" + string(snd_asset)
            + " start=" + string_format(start_time,1,3)
            + " off=" + string_format(off,1,3)
            + " arg0_is_asset=" + string(arg0_is_audio_asset));
    }

    // If request is invalid, KEEP current playback state
    if (!audio_exists(snd_asset)) {
        _audio_warn_once("scr_song_play_from_invalid_" + string(snd_asset),
            "[AUDIO] scr_song_play_from invalid requested sound " + string(snd_asset) + " (keeping current)");
        return false;
    }

    // Stop previous
    if (scr_song_is_valid_inst(st.inst)) {
        audio_stop_sound(st.inst);
    }

    if (script_exists(scr_story_seek_time)) {
        scr_story_seek_time(start_time);
    }

    // Start
    var inst = audio_play_sound(snd_asset, 1, false);

    if (!scr_song_is_valid_inst(inst)) {
        _audio_warn_once("scr_song_play_from_play_failed_" + string(snd_asset),
            "[AUDIO] scr_song_play_from failed to start sound " + string(snd_asset));
        global.song_playing = false;
        st.inst = -1;
        global.song_handle = -1;
        return false;
    }

    // Seek once (note: will only truly work for streamed sounds)
    audio_sound_set_track_position(inst, start_time + off);

    // Update state (also sets fallback clock baseline)
    st.sound_asset = snd_asset;
    st.inst = inst;
    st.started_at_time_s = start_time;
    st.chart_offset_s = off;
    st.paused = false;
    st.last_seek_time_s = start_time;
    st.last_seek_real_ms = current_time;
    st.last_known_pos_s = start_time;
    st.started_real_ms = current_time;
    st.last_raw_pos_s = -1.0;
    st.last_raw_ms = current_time;

    global.song_sound = snd_asset;
    global.song_handle = inst;
    global.song_playing = true;

    if (global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] start snd=" + scr_song_asset_label(snd_asset)
            + " [" + string(snd_asset) + "] inst=" + string(inst)
            + " seek=" + string_format(start_time + off,1,3));
    }

    return true;
}
