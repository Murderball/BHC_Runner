function scr_sfx_play(name)
{
    static logged_once = false;
    if (!logged_once)
    {
        logged_once = true;
        show_debug_message("[FMOD] scr_sfx_play stub active; SFX route not implemented.");
    }
}
