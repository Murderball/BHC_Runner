function scr_audio_settings_save()
{
    if (!variable_global_exists("AUDIO_MASTER")) global.AUDIO_MASTER = 1.0;
    global.AUDIO_MASTER = clamp(real(global.AUDIO_MASTER), 0.0, 1.0);

    var _f = "settings_audio.ini";
    ini_open(_f);
    ini_write_real("audio", "master", global.AUDIO_MASTER);
    ini_close();
}
