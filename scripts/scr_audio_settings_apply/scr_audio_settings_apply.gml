function scr_audio_settings_apply()
{
    if (!variable_global_exists("AUDIO_MASTER")) global.AUDIO_MASTER = 1.0;
    global.AUDIO_MASTER = clamp(real(global.AUDIO_MASTER), 0.0, 1.0);
    audio_master_gain(global.AUDIO_MASTER, 0.05);
}
