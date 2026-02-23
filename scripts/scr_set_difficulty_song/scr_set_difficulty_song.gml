function scr_set_difficulty_song(_diff, _reason)
{
    if (script_exists(scr_audio_route_apply)) {
        scr_audio_route_apply();
    }
}
