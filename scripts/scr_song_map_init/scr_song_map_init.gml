/// scr_song_map_init()
/// Builds one-time level/difficulty -> song sound mapping using safe name lookup.
function scr_song_map_init()
{
    if (variable_global_exists("__song_map_inited") && global.__song_map_inited
        && variable_global_exists("SONG_SND") && is_struct(global.SONG_SND)) {
        return;
    }

    function _snd(_name) {
        var idx = asset_get_index(_name);
        if (!is_real(idx) || is_nan(idx)) idx = -1;
        return idx;
    }

    global.SONG_SND = {
        "1": { easy: _snd("snd_song_1_easy"), normal: _snd("snd_song_1_normal"), hard: _snd("snd_song_1_hard") },
        "2": { easy: _snd("snd_song_2_easy"), normal: _snd("snd_song_2_normal"), hard: _snd("snd_song_2_hard") },
        "3": { easy: _snd("snd_song_3_easy"), normal: _snd("snd_song_3_normal"), hard: _snd("snd_song_3_hard") },
        "4": { easy: _snd("snd_song_4_easy"), normal: _snd("snd_song_4_normal"), hard: _snd("snd_song_4_hard") },
        "5": { easy: _snd("snd_song_5_easy"), normal: _snd("snd_song_5_normal"), hard: _snd("snd_song_5_hard") },
        "6": { easy: _snd("snd_song_6_easy"), normal: _snd("snd_song_6_normal"), hard: _snd("snd_song_6_hard") }
    };

    global.SONG_SND_READY = true;
    global.__song_map_inited = true;

    if (!variable_global_exists("AUDIO_DEBUG_LOG")) global.AUDIO_DEBUG_LOG = false;
    if (global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] song map init complete");
    }
}
