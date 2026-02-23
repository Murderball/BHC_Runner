/// scr_editor_preview_music_set(_level_index, _diff)
/// Swaps editor preview music to the level+difficulty song asset.
function scr_editor_preview_music_set(_level_index, _diff)
{
    var is_editor = variable_global_exists("editor_on") && global.editor_on;
    if (!is_editor) return;

    var preview_enabled = true;
    if (variable_global_exists("editor_preview_enabled")) preview_enabled = preview_enabled && global.editor_preview_enabled;
    if (variable_global_exists("editor_audio_preview_enabled")) preview_enabled = preview_enabled && global.editor_audio_preview_enabled;
    if (variable_global_exists("editor_preview_muted") && global.editor_preview_muted) preview_enabled = false;
    if (!preview_enabled) return;

    var level_index = clamp(floor(real(_level_index)), 1, 6);
    var diff = string_lower(string(_diff));
    if (diff != "easy" && diff != "normal" && diff != "hard") diff = "normal";

    var snd_asset = scr_level_song_sound(level_index, diff);
    if (snd_asset == -1) return;

    if (!variable_global_exists("editor_preview_sound_asset")) global.editor_preview_sound_asset = -1;
    if (!variable_global_exists("editor_preview_sound_instance")) global.editor_preview_sound_instance = -1;
    if (!variable_global_exists("editor_preview_volume")) global.editor_preview_volume = 1.0;

    if (global.editor_preview_sound_asset == snd_asset && global.editor_preview_sound_instance >= 0 && audio_is_playing(global.editor_preview_sound_instance)) {
        return;
    }

    if (global.editor_preview_sound_instance >= 0) {
        audio_stop_sound(global.editor_preview_sound_instance);
        global.editor_preview_sound_instance = -1;
    } else if (global.editor_preview_sound_asset >= 0) {
        audio_stop_sound(global.editor_preview_sound_asset);
    }

    var voice = audio_play_sound(snd_asset, 1, true);
    if (is_real(voice) && voice >= 0) {
        var vol = clamp(real(global.editor_preview_volume), 0.0, 1.0);
        audio_sound_gain(voice, vol, 0);
        global.editor_preview_sound_asset = snd_asset;
        global.editor_preview_sound_instance = voice;
        global.editor_chart_diff = diff;
    }
}
