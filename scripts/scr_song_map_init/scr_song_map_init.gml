/// scr_song_map_init()
/// Builds one-time level/difficulty -> song sound mapping using ds_maps (compatible with older runtimes)
function scr_song_map_init()
{
    // If already inited and looks valid, keep it
    if (variable_global_exists("__song_map_inited") && global.__song_map_inited
        && variable_global_exists("SONG_SND") && ds_exists(global.SONG_SND, ds_type_map))
    {
        // Compatibility alias if other code expects song_map
        global.song_map = global.SONG_SND;
        return;
    }

    if (!variable_global_exists("AUDIO_DEBUG_LOG")) global.AUDIO_DEBUG_LOG = false;

    // If re-running init, clean up prior ds_map to avoid leaks
    if (variable_global_exists("SONG_SND") && ds_exists(global.SONG_SND, ds_type_map)) {
        ds_map_destroy(global.SONG_SND);
    }

    function _snd(_name)
    {
        var idx = asset_get_index(_name);
        if (!is_real(idx) || is_nan(idx)) idx = -1;
        idx = real(idx);
        if (!audio_exists(idx)) idx = -1;
        return idx;
    }

    function _mk_level_map(_n)
    {
        var mp = ds_map_create();
        ds_map_set(mp, "easy",   _snd("snd_song_" + string(_n) + "_easy"));
        ds_map_set(mp, "normal", _snd("snd_song_" + string(_n) + "_normal"));
        ds_map_set(mp, "hard",   _snd("snd_song_" + string(_n) + "_hard"));
        return mp;
    }

    // Root map
    var root = ds_map_create();

    for (var n = 1; n <= 6; n++)
    {
        var level_mp = _mk_level_map(n);

        var key_num = string(n);                         // "3"
        var key_l1  = "level" + string(n);               // "level3"
        var key_l2  = "level" + string_format(n, 2, 0);  // "level03"

        // Store the SAME level map under multiple keys
        ds_map_set(root, key_num, level_mp);
        ds_map_set(root, key_l1,  level_mp);
        ds_map_set(root, key_l2,  level_mp);
    }

    global.SONG_SND = root;
    global.song_map = root; // alias for any other resolver

    global.SONG_SND_READY = true;
    global.__song_map_inited = true;

    if (global.AUDIO_DEBUG_LOG)
    {
        show_debug_message("[AUDIO] song map init complete");

        // Diagnostic: print missing assets
        for (var n = 1; n <= 6; n++)
        {
            var level_mp = ds_map_find_value(root, string(n));
            if (ds_exists(level_mp, ds_type_map))
            {
                var e  = ds_map_find_value(level_mp, "easy");
                var no = ds_map_find_value(level_mp, "normal");
                var h  = ds_map_find_value(level_mp, "hard");

                if (!audio_exists(e))  show_debug_message("[AUDIO] MISSING snd_song_" + string(n) + "_easy");
                if (!audio_exists(no)) show_debug_message("[AUDIO] MISSING snd_song_" + string(n) + "_normal");
                if (!audio_exists(h))  show_debug_message("[AUDIO] MISSING snd_song_" + string(n) + "_hard");
            }
            else {
                show_debug_message("[AUDIO] level map missing for " + string(n));
            }
        }
    }
}