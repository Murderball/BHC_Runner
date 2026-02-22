/// scr_disarm_boss_goto_on_song_end()
function scr_disarm_boss_goto_on_song_end()
{
    if (!instance_exists(obj_song_end_router)) return;

    var r = instance_find(obj_song_end_router, 0);
    if (!instance_exists(r)) return;

    r.current_sound = -1;
    r.current_handle = -1;
    r.start_time_us = 0;
    r.last_tick_us = get_timer();
    r.elapsed_s = 0.0;
    r.song_len_s = -1.0;
    r.target_room = -1;
    r.armed = false;
    r.triggered = false;
    r.use_stop_only = false;
}
