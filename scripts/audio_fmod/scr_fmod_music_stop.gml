function scr_fmod_music_stop()
{
    if (!variable_global_exists("fmod_music_event")) global.fmod_music_event = -1;
    var inst = global.fmod_music_event;
    if (is_real(inst) && inst >= 0) {
        fmod_studio_event_instance_stop(inst, FMOD_STUDIO_STOP_MODE.ALLOWFADEOUT);
        fmod_studio_event_instance_release(inst);
    }
    global.fmod_music_event = -1;
}
