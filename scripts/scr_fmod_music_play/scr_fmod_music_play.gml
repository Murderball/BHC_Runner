function scr_fmod_music_play(bank_name, event_name)
{
    var path = scr_fmod_event_path_build(bank_name, event_name);
    global.fmod_last_path = path;
    show_debug_message("[FMOD] PLAY REQUEST -> " + path);

    if (!variable_global_exists("fmod_ready") || !global.fmod_ready) {
        show_debug_message("[FMOD] PLAY FAIL -> " + path + " (fmod_ready=false)");
        return false;
    }

    scr_fmod_music_stop();

    var evt_desc = fmod_studio_system_get_event(path);
    if (!is_real(evt_desc) || evt_desc < 0) {
        show_debug_message("[FMOD] PLAY FAIL -> " + path + " (event lookup)");
        return false;
    }

    var evt_inst = fmod_studio_event_description_create_instance(evt_desc);
    if (!is_real(evt_inst) || evt_inst < 0) {
        show_debug_message("[FMOD] PLAY FAIL -> " + path + " (create instance)");
        return false;
    }

    var res = fmod_studio_event_instance_start(evt_inst);
    if (res != FMOD_RESULT.OK) {
        show_debug_message("[FMOD] PLAY FAIL -> " + path + " (start res=" + string(res) + ")");
        fmod_studio_event_instance_release(evt_inst);
        return false;
    }

    global.fmod_music_event = evt_inst;
    return true;
}
