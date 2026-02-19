/// scr_music_play(_snd, _tag, _fade_ms)
function scr_music_play(_snd, _tag, _fade_ms)
{
    if (!audio_exists(_snd)) return;

    // If already playing this "tag", do nothing
    if (global.music_name == string(_tag) && global.music_bus != -1) {
        if (audio_is_playing(global.music_bus)) return;
    }

    // Fade out old
    if (global.music_bus != -1) {
        if (audio_is_playing(global.music_bus)) {
            audio_sound_gain(global.music_bus, 0, max(1, _fade_ms));
            audio_stop_sound(global.music_bus); // stops immediately in some runtimes
            // If you want true fade-out timing, see the "fade manager" note below.
        }
    }

    // Start new
    global.music_bus  = audio_play_sound(_snd, 0, true);
    global.music_name = string(_tag);

    // Fade in
    audio_sound_gain(global.music_bus, 0, 0);
    audio_sound_gain(global.music_bus, 1, max(1, _fade_ms));
}
