/// obj_upgrade_controller : Clean Up
/// Stop upgrade music when leaving rm_upgrade

if (variable_global_exists("upgrade_music_handle"))
{
    if (global.upgrade_music_handle >= 0)
    {
        audio_stop_sound(global.upgrade_music_handle);
        global.upgrade_music_handle = -1;
    }
}

global.in_upgrade = false;
