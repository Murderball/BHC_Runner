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

    if (level_index != 1 && level_index != 3) {
        global.song_no_music_level = true;

        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            var no_music_key = "scr_level_song_sound_nomusic_level_" + string(level_index);
            if (!variable_struct_exists(global.__audio_warned, no_music_key)) {
                global.__audio_warned[$ no_music_key] = true;
                show_debug_message("[AUDIO] no music for level=" + string(level_index) + " (skipping resolve)");
            }
        }

        return -1;
    }

    var level_key = string(level_index);
    var snd_asset = -1;

    var level_alias = level_key;
    if (level_index == 1) level_alias = "level01";
    if (level_index == 3) level_alias = "level03";

    if (variable_global_exists("SONG_SND") && ds_exists(global.SONG_SND, ds_type_map)
        && ds_map_exists(global.SONG_SND, level_alias)) {
        var level_map = ds_map_find_value(global.SONG_SND, level_alias);
        if (ds_exists(level_map, ds_type_map) && ds_map_exists(level_map, diff)) {
            snd_asset = real(ds_map_find_value(level_map, diff));
        }

        if ((!is_real(snd_asset) || snd_asset == -1) && ds_exists(level_map, ds_type_map) && ds_map_exists(level_map, "normal")) {
            snd_asset = real(ds_map_find_value(level_map, "normal"));
        }
    }

    if (!is_real(snd_asset) || snd_asset == -1) {
        if (variable_global_exists("song_sound") && is_real(global.song_sound) && global.song_sound != -1) {
            snd_asset = global.song_sound;
        }
    }

    if (!is_real(snd_asset) || snd_asset == -1) {
        global.song_no_music_level = false;
        var warn_key = "scr_level_song_sound_missing_" + level_key + "_" + diff;
        if (!variable_struct_exists(global.__audio_warned, warn_key)) {
            global.__audio_warned[$ warn_key] = true;
            show_debug_message("[AUDIO] resolve song FAILED: level=" + level_key + " diff=" + diff);
        }
        return -1;
    }
show_debug_message("[AUDIO] resolve song DEBUG level=" + string(level_key) + " diff=" + string(diff));
show_debug_message("[AUDIO] song_map is_struct=" + string(is_struct(global.song_map)));

if (is_struct(global.song_map)) {
    show_debug_message("[AUDIO] song_map keys? (try level03/level3/3): "
        + string(variable_struct_exists(global.song_map, "level03")) + ", "
        + string(variable_struct_exists(global.song_map, "level3")) + ", "
        + string(variable_struct_exists(global.song_map, "3")));
}
    if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] resolve song level=" + level_key + " diff=" + diff
            + " -> " + asset_get_name(snd_asset) + " [" + string(snd_asset) + "]");
    }

    return snd_asset;
}
