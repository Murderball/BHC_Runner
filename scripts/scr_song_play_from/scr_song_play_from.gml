function scr_song_state_ensure()
{
    if (!variable_global_exists("song_state") || !is_struct(global.song_state)) {
        global.song_state = { sound_asset:-1, inst:-1, started_at_time_s:0.0, chart_offset_s:0.0, paused:false, last_known_pos_s:0.0, started_real_ms:current_time };
    }
    if (!variable_global_exists("song_handle")) global.song_handle = -1;
    if (!variable_global_exists("song_playing")) global.song_playing = false;
}

function scr_song_is_valid_asset(_sound_asset) { return false; }
function scr_song_is_valid_inst(_inst) { return false; }
function scr_song_asset_label(_sound_asset) { return "fmod"; }

function scr_song_get_pos_s()
{
    scr_song_state_ensure();
    if (!global.song_playing) return global.song_state.last_known_pos_s;
    var pos = global.song_state.started_at_time_s + max(0, (current_time - global.song_state.started_real_ms) / 1000.0);
    global.song_state.last_known_pos_s = pos;
    return pos;
}

function scr_song_debug_draw(_x, _y) {}

function scr_song_play_from(time_sec)
{
    scr_song_state_ensure();
    var start_time = 0.0;
    if (argument_count >= 1) start_time = max(0.0, real(argument[argument_count - 1]));

    global.song_state.started_at_time_s = start_time;
    global.song_state.started_real_ms = current_time;
    global.song_state.last_known_pos_s = start_time;
    global.song_playing = true;
    global.song_handle = -1;

    if (script_exists(scr_audio_route_apply)) scr_audio_route_apply();
    return true;
}
