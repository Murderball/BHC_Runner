scr_calibrate_hitline_time_zero();

function scr_song_play_from(time_sec) {
    if (!variable_global_exists("__audio_warned") || !is_struct(global.__audio_warned)) {
        global.__audio_warned = {};
    }

    function _audio_warn_once(_key, _msg) {
        if (!variable_struct_exists(global.__audio_warned, _key)) {
            global.__audio_warned[$ _key] = true;
            show_debug_message(_msg);
        }
    }

    var snd_asset = (variable_global_exists("song_sound")) ? global.song_sound : -1;
    var start_time = time_sec;

    // Signature: scr_song_play_from(sound_asset_index, time_sec)
    if (argument_count >= 2) {
        snd_asset = argument[0];
        start_time = argument[1];
    }

    snd_asset = real(snd_asset);

    if (!is_real(start_time)) start_time = 0.0;
    start_time = max(0.0, start_time);

    var snd_ok = is_real(snd_asset) && snd_asset != -1;

    if (!snd_ok) {
        _audio_warn_once(
            "scr_song_play_from_invalid_sound_" + string(snd_asset),
            "[AUDIO] scr_song_play_from ignored invalid numeric sound asset index: " + string(snd_asset)
        );

        global.song_handle = -1;
        global.song_playing = false;
        return false;
    }

    if (argument_count >= 2 || !variable_global_exists("song_sound") || global.song_sound != snd_asset) {
        global.song_sound = snd_asset;
    }

    if (variable_global_exists("song_handle") && global.song_handle >= 0 && audio_is_playing(global.song_handle)) {
        audio_stop_sound(global.song_handle);
    }

    if (script_exists(scr_story_seek_time)) {
        scr_story_seek_time(start_time);
    }

    global.song_handle = audio_play_sound(snd_asset, 1, false);

    if (!is_real(global.song_handle) || global.song_handle < 0) {
        _audio_warn_once(
            "scr_song_play_from_play_failed_" + string(snd_asset),
            "[AUDIO] scr_song_play_from failed to start sound asset index: " + string(snd_asset)
        );

        global.song_handle = -1;
        global.song_playing = false;
        return false;
    }

    global.song_playing = true;

    var off = (variable_global_exists("OFFSET") && is_real(global.OFFSET)) ? global.OFFSET : 0.0;
    audio_sound_set_track_position(global.song_handle, start_time + off);

    show_debug_message("[AUDIO] scr_song_play_from start: snd_asset=" + string(snd_asset)
        + " handle=" + string(global.song_handle)
        + " start_t=" + string(start_time));

    return true;
}
