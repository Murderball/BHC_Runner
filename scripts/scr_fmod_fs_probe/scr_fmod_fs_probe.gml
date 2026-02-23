/// scr_fmod_fs_probe()
function scr_fmod_fs_probe()
{
    var bank_dir = "fmod/Desktop/";
    show_debug_message("[FMOD] working_directory=" + working_directory);
    show_debug_message("[FMOD] bank_dir=" + bank_dir);

    var files = [
        "Master.bank",
        "Master.strings.bank",
        "Level_1.bank",
        "Level_3.bank",
        "Menu_Sounds.bank"
    ];

    for (var i = 0; i < array_length(files); i++)
    {
        var p = bank_dir + files[i];
        show_debug_message("[FMOD] " + (file_exists(p) ? "FOUND " : "MISSING ") + p);
    }
}