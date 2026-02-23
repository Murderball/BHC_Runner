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

    var lk = "";
    var path_src = "";
    if (variable_global_exists("editor_chart_path") && is_string(global.editor_chart_path) && global.editor_chart_path != "") {
        path_src = string_lower(global.editor_chart_path);
    }
    if (path_src == "" && variable_global_exists("editor_chart_fullpath") && is_string(global.editor_chart_fullpath) && global.editor_chart_fullpath != "") {
        path_src = string_lower(global.editor_chart_fullpath);
    }
    if (path_src == "" && variable_global_exists("chart_file") && is_string(global.chart_file) && global.chart_file != "") {
        path_src = string_lower(global.chart_file);
    }

    if (path_src != "") {
        var pp = string_pos("charts/level", path_src);
        if (pp > 0) {
            var di = pp + string_length("charts/level");
            var digits = "";
            while (di <= string_length(path_src)) {
                var ch = string_char_at(path_src, di);
                if (ch >= "0" && ch <= "9") {
                    digits += ch;
                    di += 1;
                } else {
                    break;
                }
            }
            if (digits != "") {
                var parsed_idx = clamp(real(digits), 1, 99);
                var parsed_txt = string(parsed_idx);
                if (string_length(parsed_txt) < 2) parsed_txt = "0" + parsed_txt;
                lk = "level" + parsed_txt;
            }
        }
    }

    if (lk == "" && variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY) && global.LEVEL_KEY != "") {
        lk = string_lower(global.LEVEL_KEY);
    }

    if (lk == "") {
        lk = scr_level_key_from_room(room);
        if (lk == "") lk = "level01";
    }

    var level_idx = -1;
    if (string_length(lk) >= 6) {
        level_idx = clamp(real(string_copy(lk, 6, string_length(lk) - 5)), 1, 99);
    }

    if (level_idx < 1) {
        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[EDITOR AUDIO] unable to resolve level key during diff song switch; reason=" + string(_reason));
        }
        return;
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
    if (!audio_exists(new_snd) || new_snd == -1) {
        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[EDITOR AUDIO] difficulty song switch aborted: snd_id=" + string(new_snd)
                + " level=" + string(lk) + " diff=" + d);
        }
        return;
    }

    if (variable_global_exists("editor_on") && global.editor_on) {
        show_debug_message("[EDITOR AUDIO] resolved level=" + string(lk)
            + " diff=" + d
            + " snd=" + scr_song_asset_label(new_snd)
            + " [" + string(new_snd) + "]");
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
