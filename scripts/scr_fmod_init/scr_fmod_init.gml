/// scr_fmod_init()
function scr_fmod_init()
{
    show_debug_message("========== [FMOD INIT BEGIN] ==========");

    global.fmod_ready = false;
    global.fmod_system = -1;

    var bank_dir = "fmod/Desktop/";
    show_debug_message("[FMOD] bank_dir = " + bank_dir);
    show_debug_message("[FMOD] working_directory = " + working_directory);

    // --------------------------------------------------
    // 1) FILE PROBE
    // --------------------------------------------------
    var banks = [
        "Master.bank",
        "Master.strings.bank",
        "Level_1.bank",
        "Level_3.bank",
        "Menu_Sounds.bank"
    ];

    for (var i = 0; i < array_length(banks); i++)
    {
        var path = bank_dir + banks[i];
        show_debug_message("[FMOD] " + (file_exists(path) ? "FOUND  " : "MISSING ") + path);
    }

    // --------------------------------------------------
    // 2) CREATE STUDIO SYSTEM
    // --------------------------------------------------
    if (!function_exists("fmod_studio_system_create"))
    {
        show_debug_message("[FMOD] ERROR: fmod_studio_system_create not found.");
        return;
    }

    global.fmod_system = fmod_studio_system_create();
    show_debug_message("[FMOD] system_create => " + string(global.fmod_system));

    if (global.fmod_system < 0)
    {
        show_debug_message("[FMOD] ERROR: invalid system handle.");
        return;
    }

    // --------------------------------------------------
    // 3) INITIALIZE SYSTEM
    // --------------------------------------------------
    if (!function_exists("fmod_studio_system_initialize"))
    {
        show_debug_message("[FMOD] ERROR: fmod_studio_system_initialize not found.");
        return;
    }

    var init_result = fmod_studio_system_initialize(global.fmod_system, 1024, 0, 0);
    show_debug_message("[FMOD] system_initialize => " + string(init_result));

    if (init_result != 0)
    {
        show_debug_message("[FMOD] ERROR: system initialization failed.");
        return;
    }

    // --------------------------------------------------
    // 4) LOAD BANKS
    // --------------------------------------------------
    if (!function_exists("fmod_studio_system_load_bank_file"))
    {
        show_debug_message("[FMOD] ERROR: load_bank_file function not found.");
        return;
    }

    var all_loaded = true;

    for (var i = 0; i < array_length(banks); i++)
    {
        var bpath = bank_dir + banks[i];
        var result = fmod_studio_system_load_bank_file(global.fmod_system, bpath, 0);
        show_debug_message("[FMOD] load_bank " + banks[i] + " => " + string(result));

        if (result != 0)
        {
            all_loaded = false;
        }
    }

    if (!all_loaded)
    {
        show_debug_message("[FMOD] ERROR: One or more banks failed to load.");
        return;
    }

    // --------------------------------------------------
    // 5) OPTIONAL MASTER BUS SAFETY
    // --------------------------------------------------
    if (function_exists("fmod_studio_system_get_bus"))
    {
        var bus = fmod_studio_system_get_bus(global.fmod_system, "bus:/");
        show_debug_message("[FMOD] master bus => " + string(bus));

        if (bus >= 0 && function_exists("fmod_studio_bus_set_volume"))
        {
            fmod_studio_bus_set_volume(bus, 1.0);
            show_debug_message("[FMOD] master bus volume set to 1.0");
        }
    }

    global.fmod_ready = true;

    show_debug_message("========== [FMOD INIT SUCCESS] ==========");
}