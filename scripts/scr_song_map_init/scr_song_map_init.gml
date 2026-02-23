/// scr_song_map_init()
/// ds_map based, Level 1 + Level 3 only, NO string asset_get_index lookups.
function scr_song_map_init()
{
    if (variable_global_exists("__song_map_inited") && global.__song_map_inited
        && variable_global_exists("SONG_SND") && ds_exists(global.SONG_SND, ds_type_map))
    {
        global.song_map = global.SONG_SND;
        scr_media_trace("scr_song_map_init", "<na>", "<na>", -1);
        return;
    }

    if (!variable_global_exists("AUDIO_DEBUG_LOG")) global.AUDIO_DEBUG_LOG = false;

    // Clean up previous map to avoid leaks
    if (variable_global_exists("SONG_SND") && ds_exists(global.SONG_SND, ds_type_map)) {
        ds_map_destroy(global.SONG_SND);
    }

    function _level_map(_easy, _normal, _hard)
    {
        var mp = ds_map_create();
        ds_map_set(mp, "easy",   audio_exists(_easy)   ? _easy   : -1);
        ds_map_set(mp, "normal", audio_exists(_normal) ? _normal : -1);
        ds_map_set(mp, "hard",   audio_exists(_hard)   ? _hard   : -1);
        return mp;
    }

    var root = ds_map_create();

    // --------------------------
    // LEVEL 1 (aliases)
    // --------------------------
    var lv1 = _level_map(snd_song_1_easy, snd_song_1_normal, snd_song_1_hard);
    ds_map_set(root, "1",      lv1);
    ds_map_set(root, "level1", lv1);
    ds_map_set(root, "level01",lv1);

    // --------------------------
    // LEVEL 3 (aliases)
    // --------------------------
    var lv3 = _level_map(snd_song_3_easy, snd_song_3_normal, snd_song_3_hard);
    ds_map_set(root, "3",      lv3);
    ds_map_set(root, "level3", lv3);
    ds_map_set(root, "level03",lv3);

    global.SONG_SND = root;
    global.song_map = root;

    global.SONG_SND_READY = true;
    global.__song_map_inited = true;

    scr_media_trace("scr_song_map_init", "<na>", "<na>", -1);

    if (global.AUDIO_DEBUG_LOG)
    {
        show_debug_message("[AUDIO] song map init complete (L1/L3 only)");

        // Diagnostic: ONLY for L1/L3
        var e1 = ds_map_find_value(lv1, "easy");
        var n1 = ds_map_find_value(lv1, "normal");
        var h1 = ds_map_find_value(lv1, "hard");
        if (!audio_exists(e1)) show_debug_message("[AUDIO] MISSING snd_song_1_easy");
        if (!audio_exists(n1)) show_debug_message("[AUDIO] MISSING snd_song_1_normal");
        if (!audio_exists(h1)) show_debug_message("[AUDIO] MISSING snd_song_1_hard");

        var e3 = ds_map_find_value(lv3, "easy");
        var n3 = ds_map_find_value(lv3, "normal");
        var h3 = ds_map_find_value(lv3, "hard");
        if (!audio_exists(e3)) show_debug_message("[AUDIO] MISSING snd_song_3_easy");
        if (!audio_exists(n3)) show_debug_message("[AUDIO] MISSING snd_song_3_normal");
        if (!audio_exists(h3)) show_debug_message("[AUDIO] MISSING snd_song_3_hard");
    }
}