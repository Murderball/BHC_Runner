function scr_editor_preview_music_set(_level_index, _diff)
{
    if (script_exists(scr_audio_route_apply)) {
        scr_audio_route_apply();
    }
}
