/// obj_song_end_router : Create
current_sound = -1;
current_handle = -1;
start_time_us = 0;
last_tick_us = get_timer();
elapsed_s = 0.0;
song_len_s = -1.0;
target_room = -1;
armed = false;
triggered = false;

// Fallback mode when length is invalid/unavailable.
use_stop_only = false;
