/// obj_song_end_router : Step
if (!armed || triggered) exit;

if (script_exists(scr_player_is_gameplay_room) && !scr_player_is_gameplay_room(room)) {
    scr_disarm_boss_goto_on_song_end();
    exit;
}

if (variable_global_exists("song_playing") && !global.song_playing) {
    scr_disarm_boss_goto_on_song_end();
    exit;
}

var now_us = get_timer();
if (now_us < last_tick_us) last_tick_us = now_us;
var dt_s = (now_us - last_tick_us) / 1000000.0;
last_tick_us = now_us;

var has_handle = (is_real(current_handle) && current_handle >= 0);
var is_playing = has_handle ? audio_is_playing(current_handle) : false;
var is_paused = (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED);

// Only accumulate while audio is truly playing.
if (is_playing) {
    elapsed_s += max(0.0, dt_s);
}

var should_fire = false;

// Authoritative end signal: if it stopped and we're not paused, treat as song end.
if (!is_playing && !is_paused) {
    should_fire = true;
}

// Secondary signal: measured duration reached.
if (!use_stop_only && song_len_s > 0 && elapsed_s >= song_len_s) {
    should_fire = true;
}

if (!should_fire) exit;

triggered = true;
armed = false;

if (variable_global_exists("song_handle") && global.song_handle >= 0) {
    audio_stop_sound(global.song_handle);
    global.song_handle = -1;
}
if (variable_global_exists("song_playing")) global.song_playing = false;

var _goto = target_room;
if (is_undefined(_goto) || _goto < 0) {
    if (script_exists(scr_boss_room_for_level)) {
        var _lk = (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)) ? global.LEVEL_KEY : "";
        _goto = scr_boss_room_for_level(_lk);
    }
}

// Hard disarm before room switch (prevents duplicate fire).
scr_disarm_boss_goto_on_song_end();

if (!is_undefined(_goto) && _goto >= 0) {
    room_goto(_goto);
}
