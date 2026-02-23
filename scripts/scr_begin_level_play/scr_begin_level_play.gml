/// scr_begin_level_play(start_t)
/// Starts gameplay session audio + flags at a given time (seconds)

function scr_begin_level_play(_start_t)
{
    if (!variable_global_exists("WORLD_PPS")) scr_globals_init();

    // --- make sure we're in PLAY mode ---
    global.editor_on   = false;
    global.GAME_PAUSED = false;

    // Clear any frozen pause time
    if (!variable_global_exists("pause_song_time")) global.pause_song_time = 0.0;
    global.pause_song_time = 0.0;

    // If menu music was playing, stop it
    if (variable_global_exists("menu_music_handle") && global.menu_music_handle >= 0) {
        audio_stop_sound(global.menu_music_handle);
        global.menu_music_handle = -1;
    }

    // Stop any previous song instance
    if (variable_global_exists("song_handle") && global.song_handle >= 0) {
        audio_stop_sound(global.song_handle);
        global.song_handle = -1;
    }

    if (script_exists(scr_song_state_ensure)) {
        scr_song_state_ensure();
        global.song_state.inst = -1;
    }

    global.song_playing = false;

    // ----------------------------------------------------
    // BOSS-AWARE START (ROOM-BASED ONLY)
    // Prevents boss mode leaking into main rooms (Level 1 Hard etc.)
    // ----------------------------------------------------
    var _isBoss = false;

    // Boss room match (runtime-selected)
    if (variable_global_exists("BOSS_ROOM")) {
        if (room == global.BOSS_ROOM) _isBoss = true;
    }

    // Hard safety for your known boss rooms (covers direct room_goto)
    if (!_isBoss) {
        if (room == rm_boss_1 || room == rm_boss_3) _isBoss = true;
    }

    if (_isBoss)
    {
        // Make sure boss defs are synced to THIS room/level
        if (script_exists(scr_level_prepare_for_room)) {
            scr_level_prepare_for_room(room);
        }

        // Use boss song + boss offset
        if (variable_global_exists("BOSS_SONG_SOUND")) global.song_sound = global.BOSS_SONG_SOUND;
        if (variable_global_exists("BOSS_OFFSET"))     global.OFFSET     = global.BOSS_OFFSET;

        if (_start_t < 0) _start_t = 0;
        if (audio_exists(global.song_sound)) {
            scr_song_play_from(global.song_sound, _start_t);
        } else if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] begin_level_play boss start skipped invalid song_sound=" + string(global.song_sound));
        }
        return;
    }

    // ----------------------------------------------------
    // MAIN LEVEL START (difficulty music)
    // ----------------------------------------------------
    if (!variable_global_exists("DIFF_SONG_SOUND") || !is_struct(global.DIFF_SONG_SOUND)) {
        var _level_idx = 1;
        if (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY) && string_length(global.LEVEL_KEY) >= 6) {
            _level_idx = real(string_copy(global.LEVEL_KEY, 6, string_length(global.LEVEL_KEY) - 5));
        }
        _level_idx = clamp(_level_idx, 1, 6);

        global.DIFF_SONG_SOUND = {
            easy   : scr_level_song_sound(_level_idx, "easy"),
            normal : scr_level_song_sound(_level_idx, "normal"),
            hard   : scr_level_song_sound(_level_idx, "hard")
        };
    }

    if (!variable_global_exists("song_sound") || is_undefined(global.song_sound) || global.song_sound == -1)
    {
        var d = "normal";
        if (variable_global_exists("DIFFICULTY")) d = string_lower(string(global.DIFFICULTY));
        else if (variable_global_exists("difficulty")) d = string_lower(string(global.difficulty));
        if (d != "easy" && d != "normal" && d != "hard") d = "normal";

        global.song_sound = global.DIFF_SONG_SOUND[$ d];

        if (is_undefined(global.song_sound) || global.song_sound == -1) {
            var _fallback_level = 1;
            if (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY) && string_length(global.LEVEL_KEY) >= 6) {
                _fallback_level = real(string_copy(global.LEVEL_KEY, 6, string_length(global.LEVEL_KEY) - 5));
            }
            _fallback_level = clamp(_fallback_level, 1, 6);
            global.song_sound = scr_level_song_sound(_fallback_level, "normal");
        }
    }

    if (!audio_exists(global.song_sound))
    {
        if (variable_global_exists("song_state") && is_struct(global.song_state) && audio_exists(global.song_state.sound_asset)) {
            global.song_sound = global.song_state.sound_asset;
        } else if (variable_global_exists("AUDIO_DEBUG_LOG") && global.AUDIO_DEBUG_LOG) {
            show_debug_message("[AUDIO] begin_level_play main start skipped invalid song_sound=" + string(global.song_sound));
            return;
        } else {
            return;
        }
    }

    if (_start_t < 0) _start_t = 0;
    scr_song_play_from(global.song_sound, _start_t);
}
