function scr_song_state_ensure()
{
    if (!variable_global_exists("song") || !is_struct(global.song)) {
        global.song = {
            sound_asset      : -1,
            inst             : -1,
            playing          : false,
            paused           : false,
            want_pos_s       : 0.0,
            started_at_chart_s: 0.0,
            last_pos_s       : 0.0,
            last_resync_ms   : 0,
            debug_last_log_ms: 0
        };
    }

    // Back-compat aliases used across project.
    global.song_state = global.song;
    if (!variable_global_exists("song_handle"))  global.song_handle = -1;
    if (!variable_global_exists("song_sound"))   global.song_sound = -1;
    if (!variable_global_exists("song_playing")) global.song_playing = false;
    if (!variable_global_exists("AUDIO_DEBUG_LOG")) global.AUDIO_DEBUG_LOG = false;

    return global.song;
}

function scr_song_is_valid_asset(_asset)
{
    return is_real(_asset) && !is_nan(_asset) && real(_asset) >= 0;
}

function scr_song_is_valid_inst(_inst)
{
    return is_real(_inst) && !is_nan(_inst) && real(_inst) >= 0;
}

function scr_song_stop()
{
    var s = scr_song_state_ensure();
    if (scr_song_is_valid_inst(s.inst)) audio_stop_sound(s.inst);

    s.inst = -1;
    s.playing = false;
    s.paused = false;
    global.song_handle = -1;
    global.song_playing = false;
}

function scr_song_play_asset(_asset, _loop, _gain)
{
    var s = scr_song_state_ensure();

    if (is_undefined(_loop)) _loop = true;
    if (is_undefined(_gain)) _gain = 1.0;

    if (!scr_song_is_valid_asset(_asset)) {
        show_debug_message("[AUDIO] scr_song_play_asset invalid asset: " + string(_asset));
        return -1;
    }

    scr_song_stop();

    var inst = audio_play_sound(_asset, 1, _loop);
    if (!scr_song_is_valid_inst(inst)) {
        show_debug_message("[AUDIO] scr_song_play_asset failed: " + string(_asset));
        return -1;
    }

    audio_sound_gain(inst, clamp(_gain, 0.0, 1.0), 0);

    s.sound_asset = _asset;
    s.inst = inst;
    s.playing = true;
    s.paused = false;
    s.want_pos_s = 0.0;
    s.started_at_chart_s = 0.0;
    s.last_pos_s = 0.0;
    s.last_resync_ms = current_time;

    global.song_sound = _asset;
    global.song_handle = inst;
    global.song_playing = true;

    return inst;
}

/// scr_song_play_from(time_sec)
/// Also accepts scr_song_play_from(sound_asset, time_sec, loop=true, gain=1.0)
function scr_song_play_from(time_sec)
{
    var s = scr_song_state_ensure();

    var asset = global.song_sound;
    var pos_s = 0.0;
    var loop = true;
    var gain = 1.0;

    if (argument_count >= 2) {
        asset = argument[0];
        pos_s = argument[1];
        if (argument_count >= 3) loop = argument[2];
        if (argument_count >= 4) gain = argument[3];
    } else {
        pos_s = time_sec;
    }

    if (!is_real(pos_s) || is_nan(pos_s)) pos_s = 0.0;
    pos_s = max(0.0, pos_s);

    if (!scr_song_is_valid_asset(asset)) {
        show_debug_message("[AUDIO] scr_song_play_from ignored invalid sound asset: " + string(asset));
        return -1;
    }

    var inst = scr_song_play_asset(asset, loop, gain);
    if (!scr_song_is_valid_inst(inst)) return -1;

    var seek_pos = pos_s;
    if (variable_global_exists("OFFSET") && is_real(global.OFFSET)) seek_pos += global.OFFSET;
    seek_pos = max(0.0, seek_pos);

    audio_sound_set_track_position(inst, seek_pos);

    s.want_pos_s = pos_s;
    s.started_at_chart_s = pos_s;
    s.last_pos_s = pos_s;
    s.last_resync_ms = current_time;

    if (global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] play_from snd=" + asset_get_name(asset)
            + "[" + string(asset) + "] pos=" + string_format(pos_s, 1, 3)
            + " inst=" + string(inst));
    }

    return inst;
}

function scr_song_get_pos_s()
{
    var s = scr_song_state_ensure();
    if (!scr_song_is_valid_inst(s.inst)) return 0.0;

    var pos = audio_sound_get_track_position(s.inst);
    if (!is_real(pos) || is_nan(pos)) pos = s.last_pos_s;

    if (variable_global_exists("OFFSET") && is_real(global.OFFSET)) pos -= global.OFFSET;
    if (pos < 0) pos = 0;

    s.last_pos_s = pos;
    return pos;
}

function scr_song_set_paused(_paused)
{
    var s = scr_song_state_ensure();
    var paused = !!_paused;

    if (!scr_song_is_valid_inst(s.inst)) {
        s.paused = paused;
        return;
    }

    if (paused) audio_pause_sound(s.inst); else audio_resume_sound(s.inst);
    s.paused = paused;
    global.song_playing = !paused;
}

function scr_song_switch_for_difficulty(_level_key, _diff)
{
    scr_song_state_ensure();
    if (!variable_global_exists("__song_map_inited") || !global.__song_map_inited) scr_song_map_init();

    var lk = string_lower(string(_level_key));
    if (lk == "") lk = "level03";
    if (!variable_struct_exists(global.song_map, lk)) lk = "level03";

    var d = string_lower(string(_diff));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    var row = global.song_map[$ lk];
    var pick = -1;
    if (is_struct(row) && variable_struct_exists(row, d)) pick = row[$ d];
    if (!scr_song_is_valid_asset(pick) && is_struct(row) && variable_struct_exists(row, "normal")) pick = row.normal;
    if (!scr_song_is_valid_asset(pick) && is_struct(row) && variable_struct_exists(row, "easy")) pick = row.easy;

    if (!scr_song_is_valid_asset(pick)) {
        show_debug_message("[AUDIO] switch_for_difficulty no valid asset for " + lk + "/" + d);
        return -1;
    }

    // If nothing is currently playing, only select asset; do not force-start during boot/menu.
    if (!scr_song_is_valid_inst(global.song.inst) || !audio_is_playing(global.song.inst)) {
        global.song.sound_asset = pick;
        global.song_sound = pick;
        return -1;
    }

    var t = 0.0;
    if (script_exists(scr_chart_time)) t = scr_chart_time();
    if (variable_global_exists("CHART_TIME_OFFSET_S") && is_real(global.CHART_TIME_OFFSET_S)) t += global.CHART_TIME_OFFSET_S;
    t = max(0.0, t);

    return scr_song_play_from(pick, t, true, 1.0);
}

function scr_song_debug_draw(_x, _y)
{
    var s = scr_song_state_ensure();

    var snd_name = "<none>";
    if (scr_song_is_valid_asset(s.sound_asset)) snd_name = asset_get_name(s.sound_asset);

    var audio_pos = scr_song_get_pos_s();
    var chart_pos = script_exists(scr_chart_time) ? scr_chart_time() : 0.0;
    var drift = audio_pos - chart_pos;

    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_text(_x, _y, "Song Debug");
    draw_text(_x, _y + 16, "asset: " + snd_name + " [" + string(s.sound_asset) + "]");
    draw_text(_x, _y + 32, "inst: " + string(s.inst) + " playing=" + string(s.playing) + " paused=" + string(s.paused));
    draw_text(_x, _y + 48, "audio_pos: " + string_format(audio_pos, 1, 3));
    draw_text(_x, _y + 64, "chart_time: " + string_format(chart_pos, 1, 3));
    draw_text(_x, _y + 80, "drift: " + string_format(drift, 1, 3));
}
