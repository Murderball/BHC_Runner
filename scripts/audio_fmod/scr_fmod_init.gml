function scr_fmod_init()
{
    if (variable_global_exists("fmod_ready")) return global.fmod_ready;

    global.fmod_ready = false;
    global.fmod_studio_system = 0;
    global.fmod_music_event = -1;
    global.fmod_pause_event = -1;
    global.fmod_last_music_path = "";
    global.fmod_bank_loaded = {
        Master: false,
        Master_strings: false,
        Level_1: false,
        Level_3: false,
        Menu_Sounds: false
    };

    global.fmod_music_map = {
        level01: {
            easy: "Level 1.1-Voice of Reason (Easy)",
            normal: "Level 1.2 - Voice of Reason (Normal)",
            hard: "Level 1.3 - Voice of Reason (Hard)",
            boss: "Level 1.4 -Hunger (BOSS)"
        },
        level03: {
            easy: "Level 3.1 - Bringer of Rain (Easy)",
            normal: "Level 3.2 - Bringer of Rain (Normal)",
            hard: "Level 3.3 - Bringer of Rain (Hard)",
            boss: "Level 3.4 - Faceless(BOSS)"
        }
    };
    global.fmod_menu_map = { menu: "Start_Menu", upgrade: "Upgrade_Room", pause: "Pause_Loop" };

    global.fmod_studio_system = fmod_studio_system_create();
    show_debug_message("[FMOD] studio system handle=" + string(global.fmod_studio_system));
    if (!is_real(global.fmod_studio_system) || global.fmod_studio_system <= 0) {
        show_debug_message("[FMOD] create failed: " + fmod_error_string());
        return false;
    }

    var init_res = fmod_studio_system_init(1024, FMOD_STUDIO_INIT.NORMAL, FMOD_INIT.NORMAL);
    show_debug_message("[FMOD] init result=" + string(init_res));
    if (init_res != FMOD_RESULT.OK) {
        show_debug_message("[FMOD] init failed: " + fmod_error_string(init_res));
        return false;
    }

    var bank_dir = "fmod/Desktop/";
    var files = ["Master.bank", "Master.strings.bank", "Level_1.bank", "Level_3.bank", "Menu_Sounds.bank"];
    var keys = ["Master", "Master_strings", "Level_1", "Level_3", "Menu_Sounds"];
    var ok = true;
    for (var i = 0; i < array_length(files); i++) {
        var full_path = fmod_path_bundle(bank_dir + files[i]);
        full_path = string(full_path);
        show_debug_message("[FMOD] full_path=" + full_path);

        var bank_buf = buffer_load(full_path);
        if (bank_buf < 0) {
            ok = false;
            show_debug_message("[FMOD] bank buffer load failed: " + full_path);
            continue;
        }

        var bank_size = buffer_get_size(bank_buf);
        var bank_ref = fmod_studio_system_load_bank_memory(bank_buf, bank_size, FMOD_STUDIO_LOAD_MEMORY_MODE.MEMORY, FMOD_STUDIO_LOAD_BANK.NORMAL);
        buffer_delete(bank_buf);
        if (!is_real(bank_ref) || bank_ref < 0) {
            ok = false;
            show_debug_message("[FMOD] bank load failed: " + full_path + " error=" + fmod_error_string());
        } else {
            global.fmod_bank_loaded[$ keys[i]] = true;
        }
    }

    global.fmod_ready = ok;
    if (!ok) show_debug_message("[FMOD] disabled due to bank load failure(s)");
    return global.fmod_ready;
}
