/// scr_song_map_init()
/// Builds one-time level/difficulty -> song sound mapping using safe name lookup.
function scr_song_map_init()
{
    if (variable_global_exists("__song_level_maps") && ds_exists(global.__song_level_maps, ds_type_list)) {
        var _lm_count = ds_list_size(global.__song_level_maps);
        for (var _i = 0; _i < _lm_count; _i++) {
            var _lm = ds_list_find_value(global.__song_level_maps, _i);
            if (ds_exists(_lm, ds_type_map)) ds_map_destroy(_lm);
        }
        ds_list_destroy(global.__song_level_maps);
        global.__song_level_maps = -1;
    }

    if (variable_global_exists("SONG_SND") && ds_exists(global.SONG_SND, ds_type_map)) {
        ds_map_destroy(global.SONG_SND);
        global.SONG_SND = -1;
    }

    function _snd(_name) {
        var idx = asset_get_index(_name);
        if (!is_real(idx) || is_nan(idx)) idx = -1;
        return idx;
    }

    function _level_entry(_level) {
        var m = ds_map_create();
        ds_map_add(m, "easy", _snd("snd_song_" + string(_level) + "_easy"));
        ds_map_add(m, "normal", _snd("snd_song_" + string(_level) + "_normal"));
        ds_map_add(m, "hard", _snd("snd_song_" + string(_level) + "_hard"));
        return m;
    }

    function _alias_set(_map, _key, _level_map) {
        if (!ds_map_exists(_map, _key)) ds_map_add(_map, _key, _level_map);
        else ds_map_replace(_map, _key, _level_map);
    }

    global.SONG_SND = ds_map_create();
    global.__song_level_maps = ds_list_create();

    var _lvl1 = _level_entry(1);
    var _lvl3 = _level_entry(3);

    ds_list_add(global.__song_level_maps, _lvl1);
    ds_list_add(global.__song_level_maps, _lvl3);

    _alias_set(global.SONG_SND, "1", _lvl1);
    _alias_set(global.SONG_SND, "level1", _lvl1);
    _alias_set(global.SONG_SND, "level01", _lvl1);

    _alias_set(global.SONG_SND, "3", _lvl3);
    _alias_set(global.SONG_SND, "level3", _lvl3);
    _alias_set(global.SONG_SND, "level03", _lvl3);

    global.SONG_SND_READY = true;
    global.__song_map_inited = true;

    if (!variable_global_exists("AUDIO_DEBUG_LOG")) global.AUDIO_DEBUG_LOG = false;
    if (global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] song map init complete");
    }
}
