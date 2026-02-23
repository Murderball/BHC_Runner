/// scr_set_difficulty_song(diff, reason)
/// Swaps currently selected song based on difficulty with one controlled restart.
function scr_set_difficulty_song(_diff, _reason)
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

    var lk = "level03";
    if (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)) lk = global.LEVEL_KEY;

    var level_idx = 3;
    if (string_length(lk) >= 6) {
        level_idx = clamp(real(string_copy(lk, 6, string_length(lk) - 5)), 1, 6);
    }

    global.DIFF_SONG_SOUND = {
        easy   : scr_level_song_sound(level_idx, "easy"),
        normal : scr_level_song_sound(level_idx, "normal"),
        hard   : scr_level_song_sound(level_idx, "hard")
    };

    if (variable_global_exists("song_no_music_level") && global.song_no_music_level) {
        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] diff song switch skipped (no music for level=" + string(level_idx)
                + ") reason=" + string(_reason));
        }
        return;
    }

    var new_snd = real(global.DIFF_SONG_SOUND[$ d]);
    if (!audio_exists(new_snd)) {
        new_snd = real(global.DIFF_SONG_SOUND.normal);
    }

    if (!audio_exists(new_snd) && audio_exists(global.song_state.sound_asset)) {
        new_snd = global.song_state.sound_asset;
    }

    if (!audio_exists(new_snd) && audio_exists(global.song_sound)) {
        new_snd = global.song_sound;
    }

    if (!audio_exists(new_snd)) {
        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] difficulty song switch failed: no valid asset for level=" + string(lk) + " diff=" + d);
        }
        return;
    }

    // Debounce repeated calls in same frame/reason.
    if (!variable_global_exists("_last_diff_song_switch_ms")) global._last_diff_song_switch_ms = -1000000;
    if (!variable_global_exists("_last_diff_song_switch_key")) global._last_diff_song_switch_key = "";

    var switch_key = d + "|" + string(_reason) + "|" + string(new_snd);
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
