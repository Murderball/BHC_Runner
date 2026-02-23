/// scr_fmod_update()
function scr_fmod_update()
{
    if (!variable_global_exists("fmod") || !global.fmod.ready) {
        return false;
    }

    if (!is_real(global.fmod.sys) || global.fmod.sys == 0 || global.fmod.sys == -1) {
        global.fmod.ready = false;
        global.fmod_ready = false;
        global.fmod.last_error = "Invalid FMOD system handle in scr_fmod_update.";
        show_debug_message("[FMOD] UPDATE SKIP " + global.fmod.last_error);
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
