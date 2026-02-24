/// scr_set_difficulty_song(diff, reason, [level_key])
/// Swaps currently selected song based on difficulty with one controlled restart.
function scr_set_difficulty_song(_diff, _reason, _level_key)
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
    if (argument_count >= 3) lk = string_lower(string(_level_key));

    if (lk == "" && variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)) {
        lk = string_lower(string(global.LEVEL_KEY));
    }

    if (lk == "") {
        var chart_path = "";
        if (variable_global_exists("editor_chart_path")) chart_path = string_lower(string(global.editor_chart_path));
        if (chart_path == "" && variable_global_exists("editor_chart_fullpath")) chart_path = string_lower(string(global.editor_chart_fullpath));
        if (chart_path == "" && variable_global_exists("chart_file")) chart_path = string_lower(string(global.chart_file));

        if (chart_path != "") {
            var path_pos = string_pos("charts/level", chart_path);
            if (path_pos > 0) {
                var path_digits = string_copy(chart_path, path_pos + 11, 2);
                if (string_length(path_digits) == 2 && string_digits(path_digits) == path_digits) lk = "level" + path_digits;
            }
        }
    }

    if (lk == "") {
        var room_name_now = string_lower(string(room_get_name(room)));
        var room_pos = string_pos("rm_level", room_name_now);
        if (room_pos == 1) {
            var room_digits = string_copy(room_name_now, room_pos + 8, 2);
            if (string_length(room_digits) == 2 && string_digits(room_digits) == room_digits) lk = "level" + room_digits;
        }
    }

    if (lk == "") lk = "level01";

    var level_idx = -1;
    if (string_length(lk) == 7 && string_pos("level", lk) == 1) {
        var lk_digits = string_copy(lk, 6, 2);
        if (string_digits(lk_digits) == lk_digits) {
            level_idx = clamp(real(lk_digits), 1, 6);
        }
    }

    if (level_idx < 1) {
        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] difficulty song switch skipped: no valid active level key for diff=" + d);
        }
        return;
    }

    global.LEVEL_KEY = lk;

    var in_editor = (variable_global_exists("in_editor") && global.in_editor)
        || (variable_global_exists("editor_on") && global.editor_on);
    if (in_editor) {
        show_debug_message("[EDITOR AUDIO] diff=" + d + " active_level_key=" + lk + " level_idx=" + string(level_idx));
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
        if (in_editor) show_debug_message("[EDITOR AUDIO] no valid sound for level=" + string(lk) + " diff=" + d + " (keeping current audio)");
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

    var audio_start_allowed = true;
    if (variable_global_exists("editor_on") && global.editor_on) audio_start_allowed = false;
    if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED) audio_start_allowed = false;
    if (variable_global_exists("STORY_PAUSED") && global.STORY_PAUSED) audio_start_allowed = false;
    if (variable_global_exists("paused") && global.paused) audio_start_allowed = false;
    if (variable_global_exists("in_menu") && global.in_menu) audio_start_allowed = false;
    if (variable_global_exists("in_loading") && global.in_loading) audio_start_allowed = false;
    if (variable_global_exists("STARTUP_LOADING") && global.STARTUP_LOADING) audio_start_allowed = false;

    var t_now = 0.0;
    if (script_exists(scr_song_get_pos_s)) t_now = scr_song_get_pos_s();

    global.song_sound = new_snd;

    if (!was_playing || !audio_start_allowed) {
        global.song_state.sound_asset = new_snd;
        if (!audio_start_allowed) {
            global.pending_song_start = true;
        }
        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] selected idle diff=" + d + " snd=" + scr_song_asset_label(new_snd)
                + " start_allowed=" + string(audio_start_allowed));
        }
        return;
    }

    scr_song_play_from(new_snd, t_now);
    global.pending_song_start = false;

    if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
        show_debug_message("[AUDIO] diff switch -> " + d
            + " reason=" + string(_reason)
            + " snd=" + scr_song_asset_label(new_snd)
            + " t=" + string_format(t_now, 1, 3));
    }
}
