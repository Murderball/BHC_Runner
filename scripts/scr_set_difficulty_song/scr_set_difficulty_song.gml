/// scr_set_difficulty_song(diff, reason, optional_level_key)
/// Swaps currently selected song based on difficulty with one controlled restart.
function scr_set_difficulty_song(_diff, _reason, _optional_level_key)
{
    if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss") return;

    if (!script_exists(scr_song_state_ensure)) return;
    scr_song_state_ensure();

    if (variable_global_exists("diff_swap_audio") && !global.diff_swap_audio) {
        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] diff song switch skipped (audio swap disabled) reason=" + string(_reason));
        }
        return;
    }

    var d = string_lower(string(_diff));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    var explicit_key = "";
    if (!is_undefined(_optional_level_key)) explicit_key = string_lower(string(_optional_level_key));

    var lk = explicit_key;
    if (lk == "") {
        if (script_exists(scr_active_level_key)) lk = scr_active_level_key();
        if (lk == "" && variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)) lk = string_lower(global.LEVEL_KEY);
    }

    var level_idx = -1;
    if (string_length(lk) >= 7 && string_copy(lk, 1, 5) == "level") {
        level_idx = real(string_copy(lk, 6, string_length(lk) - 5));
    }

    if (level_idx < 1) {
        scr_media_trace("scr_set_difficulty_song", lk, d, -1);
        show_debug_message("[AUDIO] difficulty song switch aborted: unresolved level key='" + string(lk)
            + "' reason=" + string(_reason));
        return;
    }

    level_idx = clamp(level_idx, 1, 99);

    var easy_snd   = scr_level_song_sound(level_idx, "easy");
    var normal_snd = scr_level_song_sound(level_idx, "normal");
    var hard_snd   = scr_level_song_sound(level_idx, "hard");

    global.DIFF_SONG_SOUND = {
        easy   : easy_snd,
        normal : normal_snd,
        hard   : hard_snd
    };

    if (variable_global_exists("song_no_music_level") && global.song_no_music_level) {
        scr_media_trace("scr_set_difficulty_song", lk, d, -1);
        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] diff song switch skipped (no music for level=" + string(level_idx)
                + ") reason=" + string(_reason));
        }
        return;
    }

    var new_snd = real(global.DIFF_SONG_SOUND[$ d]);
    if (!audio_exists(new_snd)) new_snd = real(global.DIFF_SONG_SOUND.normal);

    if (!audio_exists(new_snd)) {
        scr_media_trace("scr_set_difficulty_song", lk, d, new_snd);
        show_debug_message("[AUDIO] difficulty song switch aborted: no valid asset level=" + string(lk)
            + " diff=" + d + " reason=" + string(_reason));
        return;
    }

    scr_media_trace("scr_set_difficulty_song", lk, d, new_snd);

    // Debounce repeated calls in same frame/reason.
    if (!variable_global_exists("_last_diff_song_switch_ms")) global._last_diff_song_switch_ms = -1000000;
    if (!variable_global_exists("_last_diff_song_switch_key")) global._last_diff_song_switch_key = "";

    var switch_key = d + "|" + string(_reason) + "|" + string(new_snd) + "|" + string(lk);
    if ((current_time - global._last_diff_song_switch_ms) < 100 && global._last_diff_song_switch_key == switch_key) {
        return;
    }

    global._last_diff_song_switch_ms = current_time;
    global._last_diff_song_switch_key = switch_key;

    if (global.song_state.sound_asset == new_snd && scr_song_is_valid_inst(global.song_state.inst)) {
        global.song_sound = new_snd;
        return;
    }

    var was_playing = scr_song_is_valid_inst(global.song_state.inst)
        && (audio_is_playing(global.song_state.inst) || global.song_playing);

    var t_now = 0.0;
    if (script_exists(scr_song_get_pos_s)) t_now = scr_song_get_pos_s();

    global.song_sound = new_snd;

    if (!was_playing) {
        global.song_state.sound_asset = new_snd;
        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] selected idle diff=" + d + " snd=" + scr_song_asset_label(new_snd));
        }
        return;
    }

    scr_song_play_from(new_snd, t_now);

    if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] diff switch -> " + d
            + " reason=" + string(_reason)
            + " snd=" + scr_song_asset_label(new_snd)
            + " t=" + string_format(t_now, 1, 3));
    }
}
