/// scr_music_stop(_fade_ms)
function scr_music_stop(_fade_ms)
{
    if (global.music_bus == -1) return;

    if (audio_is_playing(global.music_bus)) {
        audio_sound_gain(global.music_bus, 0, max(1, _fade_ms));
        audio_stop_sound(global.music_bus); // immediate stop in some runtimes
    }

    global.music_bus  = -1;
    global.music_name = "";
}
