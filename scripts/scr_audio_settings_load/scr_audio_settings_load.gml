function scr_audio_settings_load()
{
    if (!variable_global_exists("AUDIO_MASTER")) global.AUDIO_MASTER = 1.0;

    var _f = "settings_audio.ini";
    if (file_exists(_f))
    {
        ini_open(_f);
        global.AUDIO_MASTER = clamp(real(ini_read_real("audio", "master", global.AUDIO_MASTER)), 0.0, 1.0);
        ini_close();
    }
    else
    {
        global.AUDIO_MASTER = clamp(real(global.AUDIO_MASTER), 0.0, 1.0);
    }
}
