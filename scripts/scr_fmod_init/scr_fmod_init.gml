function scr_fmod_init()
{
    if (!variable_global_exists("fmod_inited")) global.fmod_inited = false;

    if (global.fmod_inited) return global.fmod_ready;

    global.fmod_inited = true;
    global.fmod_ready = false;
    global.fmod_studio = -1;
    global.fmod_core_system = -1;
    global.fmod_update_invalid_handle_logged = false;
    global.fmod_music_event = noone;
    global.fmod_pause_event = noone;
    global.fmod_last_route_key = "";

    var init_ok = true;

    // FMOD extension is expected, but this stub stays defensive.
    try {
        // This extension uses a selected Studio system. Create it first and retain the handle.
        global.fmod_studio = fmod_studio_system_create();

        var init_res = fmod_studio_system_init(1024, FMOD_STUDIO_INIT.NORMAL, FMOD_INIT.NORMAL);
        if (init_res != FMOD_RESULT.OK) {
            init_ok = false;
            show_debug_message("[FMOD] init failed: " + string(init_res));
        } else {
            global.fmod_core_system = fmod_studio_system_get_core_system();
        }
    } catch (_e) {
        init_ok = false;
        show_debug_message("[FMOD] init unavailable; running in no-audio mode.");
    }

    if (init_ok)
    {
        var base = "audio/fmod/Desktop/";
        var banks = ["Master.bank", "Master.strings.bank", "Level_1.bank", "Level_3.bank", "Menu_Sounds.bank"];

        for (var i = 0; i < array_length(banks); i++)
        {
            var full_path = base + banks[i];
            try {
                var _bank = fmod_studio_system_load_bank_file(full_path, FMOD_STUDIO_LOAD_BANK.NORMAL);
            } catch (_e2) {
                init_ok = false;
                show_debug_message("[FMOD] bank load failed: " + full_path);
                break;
            }
        }
    }

    global.fmod_ready = init_ok;
    if (!global.fmod_ready) show_debug_message("[FMOD] not ready; audio scripts will no-op safely.");
    return global.fmod_ready;
}

function scr_fmod_update()
{
    if (!variable_global_exists("fmod_ready") || !global.fmod_ready) return false;

    // GMEXT-FMOD docs define fmod_studio_system_update() with no args.
    var studio_ok = variable_global_exists("fmod_studio") && is_real(global.fmod_studio) && (global.fmod_studio >= 0);
    if (!studio_ok)
    {
        if (!variable_global_exists("fmod_update_invalid_handle_logged")) global.fmod_update_invalid_handle_logged = false;
        if (!global.fmod_update_invalid_handle_logged)
        {
            global.fmod_update_invalid_handle_logged = true;
            show_debug_message("[FMOD] update skipped: invalid studio/system handle");
        }
        return false;
    }

    fmod_studio_system_update();
    return true;
}
