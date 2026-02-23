/// scr_editor_preview_music_set(level_index, diff)
/// Switches editor preview song to snd_song_<level>_<diff> without redundant restarts.
function scr_editor_preview_music_set(_level_index, _diff)
{
    if (!variable_global_exists("editor_on") || !global.editor_on) return;

    var level_index = clamp(floor(real(_level_index)), 1, 6);
    if (!variable_global_exists("__song_map_inited") || !global.__song_map_inited) {
        scr_song_map_init();
    }
    var diff = string_lower(string(_diff));
    if (diff != "easy" && diff != "normal" && diff != "hard") diff = "normal";

    var snd_asset = scr_level_song_sound(level_index, diff);
    if (!script_exists(scr_song_is_valid_asset)) return;

    if (!scr_song_is_valid_asset(snd_asset)) {
        show_debug_message("[AUDIO] editor preview music skipped invalid resolve: level=" + string(level_index)
            + " diff=" + diff + " snd_asset=" + string(snd_asset));
        return;
    }

    snd_asset = real(snd_asset);

    if (!variable_global_exists("editor_preview_sound_asset")) global.editor_preview_sound_asset = -1;
    if (!variable_global_exists("editor_preview_sound_instance")) global.editor_preview_sound_instance = -1;

    var same_sound = (global.editor_preview_sound_asset == snd_asset)
        || (variable_global_exists("song_sound") && global.song_sound == snd_asset);

    if (same_sound && variable_global_exists("song_handle") && global.song_handle >= 0 && audio_is_playing(global.song_handle)) {
        global.editor_preview_sound_asset = snd_asset;
        global.editor_preview_sound_instance = global.song_handle;
        return;
    }


    global.editor_chart_diff = diff;
    global.song_sound = snd_asset;
    global.editor_preview_sound_asset = snd_asset;

    var preview_enabled = true;
    if (variable_global_exists("editor_preview_enabled") && !global.editor_preview_enabled) preview_enabled = false;
    if (variable_global_exists("editor_audio_preview_enabled") && !global.editor_audio_preview_enabled) preview_enabled = false;
    if (variable_global_exists("editor_muted") && global.editor_muted) preview_enabled = false;

    if (!preview_enabled) {
        global.editor_preview_sound_instance = -1;
        return;
    }

    var start_t = (variable_global_exists("editor_time") && is_real(global.editor_time)) ? max(0.0, global.editor_time) : 0.0;

    if (script_exists(scr_song_play_from)) {
        scr_song_play_from(snd_asset, start_t);
    } else {
        global.song_handle = audio_play_sound(snd_asset, 1, false);
        if (global.song_handle >= 0) {
            var off = (variable_global_exists("OFFSET") && is_real(global.OFFSET)) ? global.OFFSET : 0.0;
            audio_sound_set_track_position(global.song_handle, start_t + off);
            global.song_playing = true;
        }
    }

    global.editor_preview_sound_instance = global.song_handle;

    if (global.editor_preview_sound_instance >= 0) {
        var preview_gain = 1.0;
        if (variable_global_exists("editor_preview_volume") && is_real(global.editor_preview_volume)) {
            preview_gain *= clamp(global.editor_preview_volume, 0.0, 1.0);
        }
        if (variable_global_exists("AUDIO_MASTER") && is_real(global.AUDIO_MASTER)) {
            preview_gain *= clamp(global.AUDIO_MASTER, 0.0, 1.0);
        }
        audio_sound_gain(global.editor_preview_sound_instance, clamp(preview_gain, 0.0, 1.0), 0);
    }
}
