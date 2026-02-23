/// scr_song_map_init()
/// Builds level+difficulty song mapping with defensive asset lookup.
function scr_song_map_init()
{
    if (!variable_global_exists("__song_map_inited")) global.__song_map_inited = false;

    if (global.__song_map_inited
        && variable_global_exists("song_map") && is_struct(global.song_map)
        && variable_global_exists("SONG_SND") && is_struct(global.SONG_SND))
    {
        return global.song_map;
    }

    function _song_asset_from_name(_name)
    {
        var idx = asset_get_index(string(_name));
        if (!is_real(idx) || is_nan(idx) || idx < 0) return -1;
        return idx;
    }

    function _mk_level_map(_lvl)
    {
        var level_num = string(_lvl);
        return {
            easy   : _song_asset_from_name("snd_song_" + level_num + "_easy"),
            normal : _song_asset_from_name("snd_song_" + level_num + "_normal"),
            hard   : _song_asset_from_name("snd_song_" + level_num + "_hard")
        };
    }

    global.song_map = {
        level01: _mk_level_map(1),
        level02: _mk_level_map(2),
        level03: _mk_level_map(3),
        level04: _mk_level_map(4),
        level05: _mk_level_map(5),
        level06: _mk_level_map(6)
    };

    // Back-compat map used by existing scripts.
    global.SONG_SND = {
        "1": global.song_map.level01,
        "2": global.song_map.level02,
        "3": global.song_map.level03,
        "4": global.song_map.level04,
        "5": global.song_map.level05,
        "6": global.song_map.level06
    };

    if (!variable_global_exists("AUDIO_DEBUG_LOG")) global.AUDIO_DEBUG_LOG = false;
    if (global.AUDIO_DEBUG_LOG) show_debug_message("[AUDIO] scr_song_map_init complete");

    global.SONG_SND_READY = true;
    global.__song_map_inited = true;
    return global.song_map;
}
