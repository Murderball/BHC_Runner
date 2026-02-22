function scr_audio_settings_load()
{
    if (!variable_global_exists("AUDIO_MASTER")) global.AUDIO_MASTER = 1.0;

    var _f = "settings_audio.ini";
    ini_open(_f);
    global.AUDIO_MASTER = clamp(ini_read_real("audio", "master", global.AUDIO_MASTER), 0.0, 1.0);
    ini_close();
}
