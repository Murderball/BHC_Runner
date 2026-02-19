scr_calibrate_hitline_time_zero();

function scr_song_play_from(time_sec) {
    if (time_sec < 0) time_sec = 0;

    if (global.song_handle >= 0) audio_stop_sound(global.song_handle);

    // IMPORTANT: seek story system BEFORE playback begins
    scr_story_seek_time(time_sec);

    global.song_handle = audio_play_sound(global.song_sound, 1, false);
    global.song_playing = true;

    audio_sound_set_track_position(global.song_handle, time_sec + global.OFFSET);
}
