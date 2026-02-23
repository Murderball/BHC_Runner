function scr_fmod_music_play(bank_name, event_name)
{
    var path = scr_fmod_event_path_build(bank_name, event_name);
    scr_fmod_music_stop();

    if (!variable_global_exists("fmod_ready") || !global.fmod_ready)
    {
        show_debug_message("[FMOD] not ready, cannot play: " + path);
        return false;
    }

    try {
        var evt_desc = fmod_studio_system_get_event(path);
        if (!is_real(evt_desc) || evt_desc < 0) {
            show_debug_message("[FMOD] event missing: " + path);
            return false;
        }

        var evt_inst = fmod_studio_event_description_create_instance(evt_desc);
        if (!is_real(evt_inst) || evt_inst < 0) return false;

        var res = fmod_studio_event_instance_start(evt_inst);
        if (res != FMOD_RESULT.OK) {
            fmod_studio_event_instance_release(evt_inst);
            return false;
        }

        global.fmod_music_event = evt_inst;
        return true;
    } catch (_e) {
        show_debug_message("[FMOD] play failed safely for: " + path);
        global.fmod_music_event = noone;
        return false;
    }
}
