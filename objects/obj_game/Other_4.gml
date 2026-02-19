/// obj_game : Room Start
/// Fix first-load music hiccup AND ensure correct level context per room:
/// - refresh LEVEL_KEY + per-level song/chart mapping
/// - prevent boss mode leaking into non-boss rooms
/// - ensure boss defs match the current level BEFORE any boss trigger can happen

// Force fresh init per run (prevents cached easy chunks/background)
if (!variable_global_exists("last_run_id_in_room")) global.last_run_id_in_room = -1;

// ------------------------------
// Never start gameplay systems in menu/loading rooms
// ------------------------------
if (room == rm_menu) {
    global.in_menu = true;
    global.in_loading = false;
    global.GAME_STATE = "menu";
    global.editor_on = false;
    exit;
}

if (room == rm_loading) {
    global.in_menu = false;
    global.in_loading = true;
    global.GAME_STATE = "loading";
    global.editor_on = false;
    exit;
}

// ------------------------------------------------------------
// CRITICAL: obj_game is persistent.
// Re-prepare level context every time we enter a gameplay room.
// This updates LEVEL_KEY, DIFF_SONG_SOUND, DIFF_CHART, and boss defs.
// ------------------------------------------------------------
if (script_exists(scr_level_prepare_for_room)) {
    scr_level_prepare_for_room(room);
}

// ------------------------------------------------------------
// Determine if this is a boss room
// ------------------------------------------------------------
var _isBossRoom = false;
if (variable_global_exists("BOSS_ROOM")) {
    _isBossRoom = (room == global.BOSS_ROOM);
}
// Hard safety in case BOSS_ROOM wasn't set yet
if (room == rm_boss_1 || room == rm_boss_3) _isBossRoom = true;

// ------------------------------------------------------------
// If we're NOT in the boss room, boss mode must be OFF.
// If we ARE in a boss room (even via direct room_goto), boss mode must be ON.
// ------------------------------------------------------------
if (_isBossRoom) {
    global.LEVEL_MODE = "boss";
    global.ROOM_FLOW_ENABLED = false;
} else {
    global.LEVEL_MODE = "main";
    global.ROOM_FLOW_ENABLED = true;
    if (variable_global_exists("BOSS_CHART_FILE")) global.BOSS_CHART_FILE = "";
}

// ---- ENTER PLAY MODE ----
global.in_menu = false;
global.in_loading = false;
global.GAME_STATE = "play";

global.editor_on = false;
global.GAME_PAUSED = false;

// Clear any frozen pause time
if (!variable_global_exists("pause_song_time")) global.pause_song_time = 0.0;
global.pause_song_time = 0.0;

// Ensure song vars exist
if (!variable_global_exists("song_playing")) global.song_playing = false;
if (!variable_global_exists("song_handle"))  global.song_handle  = -1;

// ------------------------------------------------------------
// AUDIO: main rooms stop carry-over; boss rooms enforce boss music
// ------------------------------------------------------------
if (!_isBossRoom)
{
    // If we entered a new gameplay room and something is still playing, stop it.
    // (Prevents carrying boss music into a main level room.)
    if (global.song_handle >= 0 && audio_is_playing(global.song_handle)) {
        audio_stop_sound(global.song_handle);
    }
    global.song_handle = -1;
    global.song_playing = false;
}
else
{
    // Boss room: make sure we're using the boss song.
    // This covers entering rm_boss_1 directly from the menu/testing.
    if (variable_global_exists("BOSS_SONG_SOUND")) {
        var _want = global.BOSS_SONG_SOUND;
        var _needRestart = false;

        if (!global.song_playing) _needRestart = true;
        if (global.song_handle < 0) _needRestart = true;
        if (global.song_handle >= 0 && !audio_is_playing(global.song_handle)) _needRestart = true;

        // If a song is playing but it's not the boss song, restart.
        if (!_needRestart) {
            if (variable_global_exists("song_sound")) {
                if (global.song_sound != _want) _needRestart = true;
            } else {
                _needRestart = true;
            }
        }

        if (_needRestart)
        {
            if (global.song_handle >= 0) audio_stop_sound(global.song_handle);
            global.song_handle = -1;
            global.song_playing = false;

            global.song_sound = _want;
            if (variable_global_exists("BOSS_OFFSET")) global.OFFSET = global.BOSS_OFFSET;

            scr_begin_level_play(0.0);
        }
    }

    // Boss rooms do NOT run difficulty-event prestart logic.
    exit;
}

// ------------------------------------------------------------
// Rebuild difficulty events ONCE per run-id
// (main rooms only)
// ------------------------------------------------------------
if (global.last_run_id_in_room != global.run_id)
{
    global.last_run_id_in_room = global.run_id;

    // Rebuild diff events from markers (this is what scr_difficulty_update reads)
    if (script_exists(scr_difficulty_events_from_markers)) {
        scr_difficulty_events_from_markers();
    }

    // Reset done flags so the event list is consistent on first load
    if (is_array(global.diff_events)) {
        var n = array_length(global.diff_events);
        for (var i = 0; i < n; i++) {
            if (is_struct(global.diff_events[i]) && variable_struct_exists(global.diff_events[i], "done")) {
                global.diff_events[i].done = false;
            }
        }
    }
}

// ------------------------------------------------------------
// PRE-SELECT t<=0 difficulty song BEFORE starting audio
// This prevents scr_set_difficulty_song from restarting audio on frame 1.
// ------------------------------------------------------------
if (!global.song_playing && global.song_handle < 0)
{
    if (is_array(global.diff_events) && array_length(global.diff_events) > 0)
    {
        // Find earliest not-done event
        var n2 = array_length(global.diff_events);
        var best_i = -1;
        var best_t = 999999;

        for (var j = 0; j < n2; j++) {
            var ev = global.diff_events[j];
            if (is_struct(ev) && variable_struct_exists(ev, "done") && ev.done) continue;

            var tj = ev.t;
            if (tj < best_t) { best_t = tj; best_i = j; }
        }

        // If earliest event happens at time 0 (or basically 0), apply selection now
        if (best_i >= 0 && best_t <= 0.0001)
        {
            var ev0 = global.diff_events[best_i];
            var d0  = string_lower(string(ev0.diff));
            if (d0 != "easy" && d0 != "normal" && d0 != "hard") d0 = "normal";

            // Set difficulty globals so everything agrees
            global.DIFFICULTY = d0;
            global.difficulty = d0;

            // Select correct song for THIS LEVEL (scr_level_prepare_for_room already set DIFF_SONG_SOUND)
            if (script_exists(scr_set_difficulty_song)) {
                scr_set_difficulty_song(d0, "prestart@0");
            }

            // Mark event done so scr_difficulty_update won't fire it again on the first frame
            if (is_struct(global.diff_events[best_i]) && variable_struct_exists(global.diff_events[best_i], "done")) {
                global.diff_events[best_i].done = true;
            }
        }
    }

    // Now start the song ONCE (using global.song_sound via scr_begin_level_play)
    scr_begin_level_play(0.0);
}
