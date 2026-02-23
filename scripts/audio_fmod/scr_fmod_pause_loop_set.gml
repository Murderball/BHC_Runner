function scr_fmod_pause_loop_set(_enabled)
{
    var enabled = (_enabled == true);
    if (!variable_global_exists("fmod_pause_event")) global.fmod_pause_event = -1;

    if (!variable_global_exists("fmod_ready") || !global.fmod_ready) return false;

    if (enabled) {
        if (is_real(global.fmod_pause_event) && global.fmod_pause_event >= 0) return true;
        var path = scr_fmod_event_path_build("Menu_Sounds", "Pause_Loop");
        var evt_desc = fmod_studio_system_get_event(path);
        if (!is_real(evt_desc) || evt_desc < 0) {
            show_debug_message("[FMOD] pause loop missing: " + path);
            return false;
        }
        var evt_inst = fmod_studio_event_description_create_instance(evt_desc);
        if (!is_real(evt_inst) || evt_inst < 0) return false;
        var res = fmod_studio_event_instance_start(evt_inst);
        if (res != FMOD_RESULT.OK) {
            fmod_studio_event_instance_release(evt_inst);
            return false;
        }
        global.fmod_pause_event = evt_inst;
        return true;
    }

    if (is_real(global.fmod_pause_event) && global.fmod_pause_event >= 0) {
        fmod_studio_event_instance_stop(global.fmod_pause_event, FMOD_STUDIO_STOP_MODE.ALLOWFADEOUT);
        fmod_studio_event_instance_release(global.fmod_pause_event);
    }
    global.fmod_pause_event = -1;
    return true;
}
