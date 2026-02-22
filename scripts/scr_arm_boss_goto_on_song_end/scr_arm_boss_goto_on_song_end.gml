/// scr_arm_boss_goto_on_song_end(sound_asset, boss_room_asset)
function scr_arm_boss_goto_on_song_end(_sound_asset, _boss_room_asset)
{
    if (!instance_exists(obj_song_end_router)) {
        instance_create_layer(0, 0, "Instances", obj_song_end_router);
    }

    var r = instance_find(obj_song_end_router, 0);
    if (!instance_exists(r)) return;

    r.current_sound = _sound_asset;
    r.current_handle = (variable_global_exists("song_handle")) ? global.song_handle : -1;
    r.target_room = _boss_room_asset;

    r.start_time_us = get_timer();
    r.last_tick_us = r.start_time_us;
    r.elapsed_s = 0.0;

    var len_s = audio_sound_length(_sound_asset);
    if (!is_real(len_s) || is_nan(len_s) || len_s <= 0) {
        r.song_len_s = -1.0;
        r.use_stop_only = true;
    } else {
        r.song_len_s = len_s;
        r.use_stop_only = false;
    }

    r.triggered = false;
    r.armed = true;
}
