/// scr_level_song_sound(level_index, diff)
/// Returns a numeric sound asset index for the level/difficulty map, or -1 if missing/invalid.
function scr_level_song_sound(_level_index, _diff)
{
    var level_index = clamp(floor(real(_level_index)), 1, 6);

    var diff = string_lower(string(_diff));
    if (diff != "easy" && diff != "normal" && diff != "hard") {
        diff = "normal";
    }

    if (script_exists(scr_song_map_init)) {
        scr_song_map_init();
    }

    if (!variable_global_exists("__audio_warned") || !is_struct(global.__audio_warned)) {
        global.__audio_warned = {};
    }

    var level_key = string(level_index);
    var snd_asset = -1;
    var used_map = false;

    if (variable_global_exists("SONG_SND") && is_struct(global.SONG_SND)
        && variable_struct_exists(global.SONG_SND, level_key)) {
        var level_map = global.SONG_SND[$ level_key];
        if (is_struct(level_map) && variable_struct_exists(level_map, diff)) {
            snd_asset = real(level_map[$ diff]);
            used_map = true;
        }
    }

    var valid_sound = is_real(snd_asset) && snd_asset != -1;

    if (!valid_sound) {
        var warn_key = "scr_level_song_sound_missing_" + level_key + "_" + diff;
        if (!variable_struct_exists(global.__audio_warned, warn_key)) {
            global.__audio_warned[$ warn_key] = true;
            show_debug_message("[AUDIO] resolve song FAILED: level=" + level_key + " diff=" + diff
                + " map=" + string(used_map)
                + " -> snd_asset=" + string(snd_asset));
        }

        return -1;
    }

    show_debug_message("[AUDIO] resolve song: level=" + level_key + " diff=" + diff
        + " map=" + string(used_map)
        + " -> snd_asset=" + string(snd_asset));

    return snd_asset;
}
