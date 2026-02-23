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
    if (global.fmod_inited) {
        show_debug_message("[FMOD INIT] already initialized; fmod_ready=" + string(global.fmod_ready));
        return global.fmod_ready;
    }

    global.fmod_inited = true;
    global.fmod_ready = false;
    global.fmod_system_handle = -1;
    global.fmod_studio = -1;
    global.fmod_core_system = -1;
    global.fmod_music_event = noone;
    global.fmod_pause_event = noone;
    global.fmod_last_path = "";
    global.fmod_route_key = "";

    global.fmod_bank_master = -1;
    global.fmod_bank_strings = -1;
    global.fmod_bank_level1 = -1;
    global.fmod_bank_level3 = -1;
    global.fmod_bank_menu = -1;

    var bank_dir = "fmod/Desktop/";
    var load_mode = FMOD_STUDIO_LOAD_MEMORY_MODE.MEMORY;
    var load_flags = FMOD_STUDIO_LOAD_BANK.NORMAL;

    show_debug_message("[FMOD INIT BEGIN]");
    show_debug_message("[FMOD] working_directory=" + working_directory);
    show_debug_message("[FMOD] bank_dir=" + bank_dir);
    show_debug_message("[FMOD] load_bank_memory mode=" + string(load_mode) + " flags=" + string(load_flags));

    var init_res = fmod_studio_system_init(1024, FMOD_STUDIO_INIT.NORMAL, FMOD_INIT.NORMAL);
    show_debug_message("[FMOD] studio init result=" + string(init_res) + " err=" + fmod_error_string(init_res));
    if (init_res != FMOD_RESULT.OK) {
        show_debug_message("[FMOD INIT FAIL] studio init failed");
        return false;
    }

    global.fmod_core_system = fmod_studio_system_get_core_system();
    show_debug_message("[FMOD] core_system=" + string(global.fmod_core_system));

    var files = [
        "Master.bank",
        "Master.strings.bank",
        "Level_1.bank",
        "Level_3.bank",
        "Menu_Sounds.bank"
    ];

    var global_bank_vars = [
        "fmod_bank_master",
        "fmod_bank_strings",
        "fmod_bank_level1",
        "fmod_bank_level3",
        "fmod_bank_menu"
    ];

    var all_loaded = true;
    var all_results_ok = true;

    for (var i = 0; i < array_length(files); i++) {
        var fname = files[i];
        var rel_path = bank_dir + fname;
        var abs_path = fmod_path_bundle(rel_path);
        var exists = file_exists(rel_path);

        show_debug_message("[FMOD] " + (exists ? "FOUND " : "MISSING ") + rel_path + " abs=" + abs_path);

        if (!exists) {
            all_loaded = false;
            continue;
        }

        var buf = buffer_load(abs_path);
        if (!is_real(buf) || buf < 0) {
            all_loaded = false;
            show_debug_message("[FMOD] buffer_load FAIL abs=" + abs_path + " buf=" + string(buf));
            continue;
        }

        var len = buffer_get_size(buf);
        show_debug_message("[FMOD] buffer_load abs=" + abs_path + " buf=" + string(buf) + " len=" + string(len));

        var bank_ref = fmod_studio_system_load_bank_memory(buf, len, load_mode, load_flags);
        var last_res = fmod_last_result();
        var err_text = fmod_error_string(last_res);
        show_debug_message("[FMOD] load_bank_memory " + fname + " => bank_ref=" + string(bank_ref) + " result=" + string(last_res) + " err=" + err_text);

        if (buffer_exists(buf)) buffer_delete(buf);

        variable_global_set(global_bank_vars[i], bank_ref);

        if (!(is_real(bank_ref) && bank_ref >= 0)) all_loaded = false;
        if (last_res != FMOD_RESULT.OK) all_results_ok = false;
    }

    global.fmod_ready = all_loaded && all_results_ok;

    if (global.fmod_ready) {
        show_debug_message("[FMOD INIT SUCCESS] fmod_ready=true");
    } else {
        show_debug_message("[FMOD INIT FAIL] fmod_ready=false all_loaded=" + string(all_loaded) + " all_results_ok=" + string(all_results_ok));
    }

    return global.fmod_ready;
}

function scr_fmod_update()
{
    if (!variable_global_exists("fmod_ready") || !global.fmod_ready) return false;
    fmod_studio_system_update();
    return true;
}
