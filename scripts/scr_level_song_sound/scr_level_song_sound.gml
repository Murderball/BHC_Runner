/// scr_level_song_sound(_level_index, _diff)
/// Returns matching snd_song_<level>_<diff> asset index, or -1 when missing.
function scr_level_song_sound(_level_index, _diff)
{
    var level_index = clamp(floor(real(_level_index)), 1, 6);

    var diff = string_lower(string(_diff));
    if (diff != "easy" && diff != "normal" && diff != "hard") {
        diff = "normal";
    }

    var asset_name = "snd_song_" + string(level_index) + "_" + diff;
    var snd_asset = asset_get_index(asset_name);

    if (!is_real(snd_asset) || snd_asset == -1) {
        return -1;
    }

    return snd_asset;
}
