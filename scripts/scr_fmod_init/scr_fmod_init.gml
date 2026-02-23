function scr_fmod_debug_probe()
{
    show_debug_message("[FMOD] working_directory=" + working_directory);

    var bank_dir = "fmod/Desktop/";
    show_debug_message("[FMOD] bank_dir=" + bank_dir);

    var banks = [
        "Master.bank",
        "Master.strings.bank",
        "Level_1.bank",
        "Level_3.bank",
        "Menu_Sounds.bank"
    ];

    for (var i = 0; i < array_length(banks); i++) {
        var bank_path = bank_dir + banks[i];
        var found = file_exists(bank_path);
        show_debug_message("[FMOD] " + (found ? "FOUND " : "MISSING ") + bank_path);
    }
}

function scr_fmod_init()
{
    if (!variable_global_exists("fmod_inited")) global.fmod_inited = false;
    if (global.fmod_inited) return global.fmod_ready;

    global.fmod_inited = true;
    global.fmod_ready = false;
    global.fmod_system_handle = -1;
    global.fmod_studio = -1;
    global.fmod_core_system = -1;
    global.fmod_music_event = noone;
    global.fmod_pause_event = noone;
    global.fmod_last_path = "";
    global.fmod_route_key = "";

    var bank_dir = "fmod/Desktop/";
    show_debug_message("[FMOD] bank_dir=" + bank_dir);

    global.fmod_studio = fmod_studio_system_create();
    global.fmod_system_handle = global.fmod_studio;
    show_debug_message("[FMOD] system_handle=" + string(global.fmod_system_handle));

    var init_res = fmod_studio_system_init(1024, FMOD_STUDIO_INIT.NORMAL, FMOD_INIT.NORMAL);
    if (init_res != FMOD_RESULT.OK) {
        show_debug_message("[FMOD] init FAIL res=" + string(init_res) + " err=" + fmod_error_string(init_res));
        return false;
    }

    global.fmod_core_system = fmod_studio_system_get_core_system();

    var files = [
        "Master.bank",
        "Master.strings.bank",
        "Level_1.bank",
        "Level_3.bank",
        "Menu_Sounds.bank"
    ];

    var all_loaded = true;
    for (var i = 0; i < array_length(files); i++) {
        var fname = files[i];
        var rel_path = bank_dir + fname;

        if (!file_exists(rel_path)) {
            all_loaded = false;
            show_debug_message("[FMOD] load_bank FAIL " + fname + " (missing file: " + rel_path + ")");
            continue;
        }

        var bank_ref = fmod_studio_system_load_bank_file(rel_path, FMOD_STUDIO_LOAD_BANK.NORMAL);
        if (is_real(bank_ref) && bank_ref >= 0) {
            show_debug_message("[FMOD] load_bank OK " + fname);
        } else {
            all_loaded = false;
            show_debug_message("[FMOD] load_bank FAIL " + fname + " err=" + fmod_error_string());
        }
    }

    global.fmod_ready = all_loaded;

    if (global.fmod_ready) {
        show_debug_message("[FMOD] ready=true");
    } else {
        show_debug_message("[FMOD] ready=false");
    }

    show_debug_message("[FMOD] master gain set to 1.0 (no compatible bus/VCA setter exposed in current wrapper)");

    return global.fmod_ready;
}

function scr_fmod_update()
{
    if (!variable_global_exists("fmod_ready") || !global.fmod_ready) return false;
    fmod_studio_system_update();
    return true;
}
