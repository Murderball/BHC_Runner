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

        var miss_level_key = "level" + ((level_index < 10) ? ("0" + string(level_index)) : string(level_index));
        scr_media_trace("scr_level_song_sound", miss_level_key, diff, -1);
        return -1;
    }

    var level_key = string(level_index);
    var level_alias = (level_index == 1) ? "level01" : "level03";
    var snd_asset = -1;

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
        global.song_no_music_level = false;
        var warn_key = "scr_level_song_sound_missing_" + level_key + "_" + diff;
        if (!variable_struct_exists(global.__audio_warned, warn_key)) {
            global.__audio_warned[$ warn_key] = true;
            show_debug_message("[AUDIO] resolve song FAILED: level=" + level_key + " diff=" + diff);
        }
        scr_media_trace("scr_level_song_sound", level_alias, diff, -1);
        return -1;
    }

    global.song_no_music_level = false;
    scr_media_trace("scr_level_song_sound", level_alias, diff, snd_asset);

    if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] resolve song level=" + level_key + " diff=" + diff
            + " -> " + scr_song_asset_label(snd_asset) + " [" + string(snd_asset) + "]");
    }

    return snd_asset;
}
