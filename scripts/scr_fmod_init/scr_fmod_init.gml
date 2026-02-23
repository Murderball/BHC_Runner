/// scr_fmod_init()
function scr_fmod_init()
{
    show_debug_message("========== [FMOD INIT BEGIN] ==========");

    global.fmod = {
        ready: false,
        sys: 0,
        core: 0,
        banks: {},
        last_error: "",
        bank_dir: "fmod/Desktop/"
    };

    // Backward-compatible globals used by existing scripts.
    global.fmod_ready = false;
    global.fmod_inited = false;
    global.fmod_studio_system = -1;

    global.fmod_bank_master = -1;
    global.fmod_bank_strings = -1;
    global.fmod_bank_level1 = -1;
    global.fmod_bank_level3 = -1;
    global.fmod_bank_menu = -1;

    global.fmod_music_event = noone;
    global.fmod_pause_event = noone;

    show_debug_message("[FMOD] bank_dir=" + string(global.fmod.bank_dir));
    show_debug_message("[FMOD] working_directory=" + string(working_directory));

    global.fmod.sys = fmod_studio_system_create();
    global.fmod_studio_system = global.fmod.sys;
    show_debug_message("[FMOD] create sys=" + string(global.fmod.sys) + " is_real=" + string(is_real(global.fmod.sys)));
    show_debug_message("[FMOD] global.fmod_studio_system=" + string(global.fmod_studio_system));

    if (!is_real(global.fmod.sys) || global.fmod.sys == 0 || global.fmod.sys == -1) {
        var create_result = fmod_last_result();
        global.fmod.last_error = "fmod_studio_system_create failed: " + fmod_error_string(create_result);
        show_debug_message("[FMOD] ERROR " + global.fmod.last_error);
        global.fmod_inited = true;
        return false;
    }

    if (!variable_global_exists("fmod_studio_system") || is_undefined(global.fmod_studio_system) || global.fmod_studio_system == 0 || global.fmod_studio_system == -1) {
        global.fmod.last_error = "Invalid Studio System handle after create.";
        show_debug_message("[FMOD] ERROR " + global.fmod.last_error);
        global.fmod_inited = true;
        return false;
    }

    var init_result = fmod_studio_system_init(1024, FMOD_STUDIO_INIT.NORMAL, FMOD_INIT.NORMAL);
    show_debug_message("[FMOD] init result=" + string(init_result) + " error=\"" + fmod_error_string(init_result) + "\"");

    if (init_result != FMOD_RESULT.OK) {
        global.fmod.last_error = "fmod_studio_system_init failed: " + fmod_error_string(init_result);
        show_debug_message("[FMOD] ERROR " + global.fmod.last_error);
        global.fmod_inited = true;
        return false;
    }

    global.fmod.core = fmod_studio_system_get_core_system();
    show_debug_message("[FMOD] core=" + string(global.fmod.core) + " is_real=" + string(is_real(global.fmod.core)));

    var banks_ok = scr_fmod_load_banks();
    if (!banks_ok) {
        if (global.fmod.last_error == "") {
            global.fmod.last_error = "Bank load failed.";
        }
        show_debug_message("[FMOD] ERROR " + global.fmod.last_error);
        global.fmod_inited = true;
        return false;
    }

    var update_result = fmod_studio_system_update();
    show_debug_message("[FMOD] first update result=" + string(update_result) + " error=\"" + fmod_error_string(update_result) + "\"");
    if (update_result != FMOD_RESULT.OK) {
        global.fmod.last_error = "fmod_studio_system_update failed: " + fmod_error_string(update_result);
        show_debug_message("[FMOD] ERROR " + global.fmod.last_error);
        global.fmod_inited = true;
        return false;
    }

    global.fmod.ready = true;
    global.fmod_ready = true;
    global.fmod_inited = true;
    global.fmod.last_error = "";

    show_debug_message("========== [FMOD INIT SUCCESS] ready=true ==========");
    return true;
}
