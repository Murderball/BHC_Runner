function scr_fmod_music_play(_path)
{
    if (!variable_global_exists("fmod_ready") || !global.fmod_ready) {
        show_debug_message("[FMOD] music play skipped (not ready): " + string(_path));
        return false;
    }

    var path = string(_path);
    if (path == "") return false;

    scr_fmod_music_stop();

    var evt_desc = fmod_studio_system_get_event(path);
    if (!is_real(evt_desc) || evt_desc < 0) {
        show_debug_message("[FMOD] missing event: " + path + " error=" + fmod_error_string());
        return false;
    }

    var evt_inst = fmod_studio_event_description_create_instance(evt_desc);
    if (!is_real(evt_inst) || evt_inst < 0) {
        show_debug_message("[FMOD] failed create instance: " + path + " error=" + fmod_error_string());
        return false;
    }

    var res = fmod_studio_event_instance_start(evt_inst);
    if (res != FMOD_RESULT.OK) {
        show_debug_message("[FMOD] failed start event: " + path + " error=" + fmod_error_string(res));
        fmod_studio_event_instance_release(evt_inst);
        return false;
    }

    global.fmod_music_event = evt_inst;
    show_debug_message("[FMOD] music -> " + path);
    return true;
}
