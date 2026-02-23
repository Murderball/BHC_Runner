/// scr_level_song_sound(level_index, diff)
/// Returns a numeric sound asset index for the level/difficulty map, or -1 if missing/invalid.
function scr_level_song_sound(_level_index, _diff)
{
    var level_index = clamp(floor(real(_level_index)), 1, 6);

    var diff = string_lower(string(_diff));
    if (diff != "easy" && diff != "normal" && diff != "hard") {
        diff = "normal";
    }

    if (!variable_global_exists("__song_map_inited") || !global.__song_map_inited) {
        scr_song_map_init();
    }

    if (!variable_global_exists("__audio_warned") || !is_struct(global.__audio_warned)) {
        global.__audio_warned = {};
    }

    var level_key = string(level_index);
    var snd_asset = -1;

    if (variable_global_exists("SONG_SND") && is_struct(global.SONG_SND)
        && variable_struct_exists(global.SONG_SND, level_key)) {
        var level_map = global.SONG_SND[$ level_key];
        if (is_struct(level_map) && variable_struct_exists(level_map, diff)) {
            snd_asset = real(level_map[$ diff]);
        }

        if ((!is_real(snd_asset) || snd_asset == -1) && variable_struct_exists(level_map, "normal")) {
            snd_asset = real(level_map.normal);
        }
    }

    if (!is_real(snd_asset) || snd_asset == -1) {
        if (variable_global_exists("song_sound") && is_real(global.song_sound) && global.song_sound != -1) {
            snd_asset = global.song_sound;
        }
    }

    if (!is_real(snd_asset) || snd_asset == -1) {
        var warn_key = "scr_level_song_sound_missing_" + level_key + "_" + diff;
        if (!variable_struct_exists(global.__audio_warned, warn_key)) {
            global.__audio_warned[$ warn_key] = true;
            show_debug_message("[AUDIO] resolve song FAILED: level=" + level_key + " diff=" + diff);
        }
        return -1;
    }

    if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] resolve song level=" + level_key + " diff=" + diff
            + " -> " + asset_get_name(snd_asset) + " [" + string(snd_asset) + "]");
    }

    return snd_asset;
}
