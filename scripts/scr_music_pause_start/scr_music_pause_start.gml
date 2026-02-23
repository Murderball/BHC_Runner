function scr_music_pause_start()
{
    if (!variable_global_exists("fmod_pause_inst")) global.fmod_pause_inst = 0;
    if (!variable_global_exists("PAUSE_MUSIC_EVENT")) global.PAUSE_MUSIC_EVENT = "event:/music_pause";

    // Normalize in case someone sets it to "music_pause"
    var ev = string(global.PAUSE_MUSIC_EVENT);
    if (string_pos("event:/", ev) != 1) ev = "event:/" + ev;

    if (global.fmod_pause_inst != 0 && fmod_studio_event_instance_is_valid(global.fmod_pause_inst)) return;

    // Start pause music
    global.fmod_pause_inst = scr_fmod_event_play(ev, 0, 1.0);
}
