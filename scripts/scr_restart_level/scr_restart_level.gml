/// scr_restart_level()
/// Restarts the current level from the top.
/// - Arcade: keep current difficulty
/// - Story: force normal difficulty
function scr_restart_level()
{
    // Decide mode
    var mode = "story";
    if (variable_global_exists("game_mode")) mode = string_lower(string(global.game_mode));

    // Decide difficulty
    var d = "normal";

    if (mode == "arcade")
    {
        if (variable_global_exists("difficulty")) d = string_lower(string(global.difficulty));
        else if (variable_global_exists("DIFFICULTY")) d = string_lower(string(global.DIFFICULTY));
    }
    else
    {
        // Story always normal
        d = "normal";
    }

    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    // Persist selection for the next boot
    global.DIFFICULTY = d;
    global.difficulty = d;

    // Apply immediately (safe if called mid-run)
    if (script_exists(scr_apply_difficulty))  scr_apply_difficulty(d, "restart_level");
    if (script_exists(scr_set_difficulty_song)) scr_set_difficulty_song(d, "restart_level", scr_active_level_key());

    // Stop audio cleanly (prevents overlap during reload)
    if (variable_global_exists("song_handle") && global.song_handle >= 0) {
        audio_stop_sound(global.song_handle);
        global.song_handle = -1;
    }
    global.song_playing = false;

    if (variable_global_exists("story_npc_handle") && global.story_npc_handle >= 0) {
        audio_stop_sound(global.story_npc_handle);
        global.story_npc_handle = -1;
    }

    // Clear pause flags
    global.GAME_PAUSED = false;
    if (variable_global_exists("pause_song_time")) global.pause_song_time = 0.0;

    // Hard reset cached session state (story markers, chunk/bg managers, chart loaded flags)
    if (script_exists(scr_reset_play_session)) scr_reset_play_session();

    // ------------------------------------------------------------
    // CRITICAL: obj_game is persistent, so its Create() won't run again.
    // scr_reset_play_session() clears global.chart, so we MUST reload it here.
    // ------------------------------------------------------------

    // Ensure chart_file points at the right chart for this restart
    if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss")
    {
        if (variable_global_exists("BOSS_CHART_FILE")) global.chart_file = global.BOSS_CHART_FILE;
    }
    else
    {
        // Normal level: chart determined by difficulty mapping
        if (variable_global_exists("DIFF_CHART") && is_struct(global.DIFF_CHART))
        {
            if (variable_struct_exists(global.DIFF_CHART, d))
                global.chart_file = global.DIFF_CHART[$ d];
        }
    }

    // Reload run data NOW (before entering loading/next room)
    if (script_exists(scr_chart_load))   scr_chart_load();
    if (script_exists(scr_phrases_load)) scr_phrases_load();

    // Go through your loading room
    global.in_menu        = false;
    global.in_loading     = true;
    global.play_requested = true;
    global.GAME_STATE     = "loading";

    // Restart the SAME room you’re currently in (works for rm_level03 or boss rooms)
    global.next_room = room;

    room_goto(rm_loading);
}
