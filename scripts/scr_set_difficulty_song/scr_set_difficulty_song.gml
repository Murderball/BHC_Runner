/// scr_safe_asset_name(asset) -> string
function scr_safe_asset_name(_asset)
{
    if (!is_real(_asset) || is_nan(_asset) || floor(_asset) <= -1) return "<none>";

    // Runtime-safe fallback: do not call asset_get_name in this project/runtime path.
    return "<id:" + string(_asset) + ">";
}

/// scr_chart_key_for_current_level(diff) -> chart path using canonical level resolver.
function scr_chart_key_for_current_level(_diff)
{
    var d = string_lower(string(_diff));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    var level_key = scr_level_resolve_key();
    var level_idx = scr_level_key_to_index(level_key);
    return scr_chart_fullpath(scr_chart_filename(level_idx, d, false));
}

/// scr_song_asset_for_current_level(diff) -> sound asset index using canonical level resolver.
function scr_song_asset_for_current_level(_diff)
{
    var d = string_lower(string(_diff));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    var level_key = scr_level_resolve_key();
    var level_idx = scr_level_key_to_index(level_key);
    return scr_level_song_sound(level_idx, d);
}

/// scr_reload_level_media_for_diff(diff)
/// Reload chart+audio for currently resolved level; never mutates level id.
function scr_reload_level_media_for_diff(_diff)
{
    var d = string_lower(string(_diff));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    var level_key = scr_level_resolve_key();
    global.level_key = level_key;
    global.LEVEL_KEY = level_key;

    global.DIFFICULTY = d;
    global.difficulty = d;

    var chart_path = scr_chart_key_for_current_level(d);
    if (is_string(chart_path) && chart_path != "") {
        global.chart_file = chart_path;
        if (script_exists(scr_chart_load)) scr_chart_load();
    }

    var snd = scr_song_asset_for_current_level(d);
    var snd_valid = is_real(snd) && !is_nan(snd) && snd > -1 && audio_exists(snd);
    if (snd_valid) {
        if (script_exists(scr_set_difficulty_song)) scr_set_difficulty_song(d, "diff_hotkey");
    } else if (variable_global_exists("DEBUG_MEDIA_RELOAD") && global.DEBUG_MEDIA_RELOAD) {
        show_debug_message("[DIFF HOTKEY] WARN invalid snd for level_key=" + string(level_key)
            + " diff=" + string(d) + " snd=" + scr_safe_asset_name(snd));
    }

    if (variable_global_exists("DEBUG_MEDIA_RELOAD") && global.DEBUG_MEDIA_RELOAD)
    {
        var snd_name = scr_safe_asset_name(snd);
        show_debug_message("[DIFF HOTKEY] room=" + string(room_get_name(room))
            + " level_key=" + string(level_key)
            + " diff=" + string(d)
            + " chart=" + string(chart_path)
            + " snd=" + snd_name);
    }
}

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

    var lk = scr_level_resolve_key();
    global.level_key = lk;
    global.LEVEL_KEY = lk;

    global.DIFF_SONG_SOUND = {
        easy   : scr_song_asset_for_current_level("easy"),
        normal : scr_song_asset_for_current_level("normal"),
        hard   : scr_song_asset_for_current_level("hard")
    };

    if (variable_global_exists("song_no_music_level") && global.song_no_music_level) {
        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] diff song switch skipped (no music for level=" + string(lk)
                + ") reason=" + string(_reason));
        }
        return;
    }

    var new_snd = real(global.DIFF_SONG_SOUND[$ d]);
    if (!audio_exists(new_snd)) new_snd = real(global.DIFF_SONG_SOUND.normal);
    if (!audio_exists(new_snd) && audio_exists(global.song_state.sound_asset)) new_snd = global.song_state.sound_asset;
    if (!audio_exists(new_snd) && audio_exists(global.song_sound)) new_snd = global.song_sound;

    if (!audio_exists(new_snd)) {
        if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] difficulty song switch failed: no valid asset for level=" + string(lk) + " diff=" + d);
        }
        return;
    }

    if (!variable_global_exists("_last_diff_song_switch_ms")) global._last_diff_song_switch_ms = -1000000;
    if (!variable_global_exists("_last_diff_song_switch_key")) global._last_diff_song_switch_key = "";

    var switch_key = d + "|" + string(_reason) + "|" + string(new_snd);
    if ((current_time - global._last_diff_song_switch_ms) < 100 && global._last_diff_song_switch_key == switch_key) return;

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
