/// scr_fmod_init()
function scr_fmod_init()
{
    show_debug_message("========== [FMOD INIT BEGIN] ==========");

    global.fmod_ready = false;
    global.fmod_inited = false;

    global.fmod_bank_master = -1;
    global.fmod_bank_strings = -1;
    global.fmod_bank_level1 = -1;
    global.fmod_bank_level3 = -1;
    global.fmod_bank_menu = -1;

    var bank_dir = "fmod/Desktop/";
    show_debug_message("[FMOD] bank_dir = " + bank_dir);
    show_debug_message("[FMOD] working_directory = " + string(working_directory));

    var mode = FMOD_STUDIO_LOAD_MEMORY_MODE.MEMORY;
    var flags = FMOD_STUDIO_LOAD_BANK.NORMAL;
    show_debug_message("[FMOD] load_bank_memory mode=" + string(mode) + " flags=" + string(flags));

    var banks = [
        { file: "Master.bank", store: "fmod_bank_master" },
        { file: "Master.strings.bank", store: "fmod_bank_strings" },
        { file: "Level_1.bank", store: "fmod_bank_level1" },
        { file: "Level_3.bank", store: "fmod_bank_level3" },
        { file: "Menu_Sounds.bank", store: "fmod_bank_menu" }
    ];

    var all_ok = true;
    var last_result_ok = true;

    for (var i = 0; i < array_length(banks); i++)
    {
        var rel = bank_dir + banks[i].file;
        show_debug_message("[FMOD] " + (file_exists(rel) ? "FOUND " : "MISSING ") + rel);

        var abs = fmod_path_bundle(rel);
        var buf = -1;
        var len = -1;
        var bank_ref = -1;

        if (!file_exists(rel)) {
            all_ok = false;
            show_debug_message("[FMOD] SKIP load (missing file): " + rel + " abs=" + string(abs));
            variable_global_set(banks[i].store, -1);
            continue;
        }

        buf = buffer_load(abs);
        if (!buffer_exists(buf)) {
            all_ok = false;
            show_debug_message("[FMOD] buffer_load failed abs=" + string(abs) + " buf=" + string(buf));
            variable_global_set(banks[i].store, -1);
            continue;
        }

        len = buffer_get_size(buf);
        show_debug_message("[FMOD] buffer_load abs=" + string(abs) + " buf=" + string(buf) + " len=" + string(len));

        bank_ref = fmod_studio_system_load_bank_memory(buf, len, mode, flags);

        var last_result = fmod_last_result();
        var last_error = fmod_error_string(last_result);
        show_debug_message("[FMOD] load_bank_memory " + banks[i].file + " => bank_ref=" + string(bank_ref) + " result=" + string(last_result) + " error=\"" + string(last_error) + "\"");

        if (!is_real(bank_ref) || bank_ref < 0) {
            all_ok = false;
        }

        if (last_result != FMOD_RESULT.OK) {
            last_result_ok = false;
        }

        variable_global_set(banks[i].store, bank_ref);

        if (buffer_exists(buf)) {
            buffer_delete(buf);
            show_debug_message("[FMOD] buffer_delete buf=" + string(buf));
        }
    }

    fmod_studio_system_update();

    global.fmod_ready = all_ok && last_result_ok
        && global.fmod_bank_master >= 0
        && global.fmod_bank_strings >= 0
        && global.fmod_bank_level1 >= 0
        && global.fmod_bank_level3 >= 0
        && global.fmod_bank_menu >= 0;

    global.fmod_inited = true;

    if (global.fmod_ready) {
        show_debug_message("========== [FMOD INIT SUCCESS] fmod_ready=true ==========");
    } else {
        show_debug_message("========== [FMOD INIT FAIL] fmod_ready=false all_ok=" + string(all_ok) + " last_result_ok=" + string(last_result_ok) + " ==========");
    }

    return global.fmod_ready;
}
