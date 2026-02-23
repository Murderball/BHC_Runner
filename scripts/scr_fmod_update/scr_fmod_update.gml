/// scr_fmod_update()
function scr_fmod_update()
{
    if (!variable_global_exists("fmod_ready") || !global.fmod_ready) {
        return false;
    }

    var result = fmod_studio_system_update();
    if (result != FMOD_RESULT.OK) {
        global.fmod.ready = false;
        global.fmod_ready = false;
        global.fmod.last_error = "fmod_studio_system_update failed: " + fmod_error_string(result);
        show_debug_message("[FMOD] UPDATE FAIL " + global.fmod.last_error);
        return false;
    }

    return true;
}
