function scr_music_pause_stop()
{
    if (variable_global_exists("fmod_pause_inst") && global.fmod_pause_inst != 0) {
        scr_fmod_event_stop(global.fmod_pause_inst, true, true);
        global.fmod_pause_inst = 0;
    }
}
