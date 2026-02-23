/// scr_level_song_sound(level_index, diff)
/// Returns a sound asset id for snd_song_<level>_<diff>, or -1 if missing/invalid.
function scr_level_song_sound(_level_index, _diff)
{
    var level_index = clamp(floor(real(_level_index)), 1, 6);

    var diff = string_lower(string(_diff));
    if (diff != "easy" && diff != "normal" && diff != "hard") {
        diff = "normal";
    }

    var asset_name = "snd_song_" + string(level_index) + "_" + diff;
    var snd_asset = asset_get_index(asset_name);

    var valid_sound = is_real(snd_asset)
        && snd_asset != -1
        && asset_get_type(snd_asset) == asset_sound;

    if (!valid_sound) {
        if (!variable_global_exists("__audio_warned") || !is_struct(global.__audio_warned)) {
            global.__audio_warned = {};
        }

        var warn_key = "scr_level_song_sound_missing_" + asset_name;
        if (!variable_struct_exists(global.__audio_warned, warn_key)) {
            global.__audio_warned[$ warn_key] = true;
            show_debug_message("[AUDIO] Missing/invalid song asset: " + asset_name + " (index=" + string(snd_asset) + ")");
        }

        return -1;
    }

    return snd_asset;
}
