/// scr_fmod_load_banks()
function scr_fmod_load_banks()
{
    show_debug_message("[FMOD] ---------- load banks begin ----------");

    if (!variable_global_exists("fmod")) {
        show_debug_message("[FMOD] ERROR global.fmod missing before bank load");
        return false;
    }

    show_debug_message("[FMOD] bank load sys=" + string(global.fmod.sys) + " is_real=" + string(is_real(global.fmod.sys)));
    show_debug_message("[FMOD] bank load global.fmod_studio_system=" + string(global.fmod_studio_system));

    if (!variable_global_exists("fmod_studio_system") || is_undefined(global.fmod_studio_system) || global.fmod_studio_system == 0 || global.fmod_studio_system == -1) {
        global.fmod.last_error = "Invalid Studio System handle before bank load.";
        show_debug_message("[FMOD] ERROR " + global.fmod.last_error);
        return false;
    }

    var bank_files = [
        { key: "Master", file: "Master.bank", legacy_key: "fmod_bank_master" },
        { key: "Master_strings", file: "Master.strings.bank", legacy_key: "fmod_bank_strings" },
        { key: "Level_1", file: "Level_1.bank", legacy_key: "fmod_bank_level1" },
        { key: "Level_3", file: "Level_3.bank", legacy_key: "fmod_bank_level3" },
        { key: "Menu_Sounds", file: "Menu_Sounds.bank", legacy_key: "fmod_bank_menu" }
    ];

    var flags = FMOD_STUDIO_LOAD_BANK.NORMAL;
    var all_ok = true;

    for (var i = 0; i < array_length(bank_files); i++) {
        var rel_path = global.fmod.bank_dir + bank_files[i].file;
        var full_path = string(fmod_path_bundle(rel_path));

        show_debug_message("[FMOD] full_path=" + full_path);

        if (!file_exists(rel_path) && !file_exists(full_path)) {
            all_ok = false;
            global.fmod.last_error = "Missing bank file: " + rel_path;
            variable_global_set(bank_files[i].legacy_key, -1);
            global.fmod.banks[$ bank_files[i].key] = -1;
            show_debug_message("[FMOD] ERROR " + global.fmod.last_error);
            continue;
        }

        var bank_buf = buffer_load(full_path);
        if (bank_buf < 0) {
            all_ok = false;
            global.fmod.last_error = "buffer_load failed for bank: " + full_path;
            variable_global_set(bank_files[i].legacy_key, -1);
            global.fmod.banks[$ bank_files[i].key] = -1;
            show_debug_message("[FMOD] ERROR " + global.fmod.last_error);
            continue;
        }

        var bank_len = buffer_get_size(bank_buf);
        var bank_ref = fmod_studio_system_load_bank_memory(bank_buf, bank_len, FMOD_STUDIO_LOAD_MEMORY_MODE.MEMORY, flags);
        buffer_delete(bank_buf);

        var load_result = fmod_last_result();
        var load_error = fmod_error_string(load_result);

        show_debug_message("[FMOD] load_bank_memory " + bank_files[i].file + " len=" + string(bank_len) + " -> bank_ref=" + string(bank_ref) + " result=" + string(load_result) + " error=\"" + string(load_error) + "\"");

        var bank_ok = is_real(bank_ref) && (bank_ref >= 0) && (load_result == FMOD_RESULT.OK);
        if (!bank_ok) {
            all_ok = false;
            global.fmod.last_error = "Failed to load bank '" + bank_files[i].file + "': " + string(load_error);
            bank_ref = -1;
        }

        variable_global_set(bank_files[i].legacy_key, bank_ref);
        global.fmod.banks[$ bank_files[i].key] = bank_ref;
    }

    show_debug_message("[FMOD] ---------- load banks end all_ok=" + string(all_ok) + " ----------");
    return all_ok;
}
