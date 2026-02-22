/// scr_return_to_title()
/// HARD reset play-session state so a new run starts clean.

function scr_return_to_title()
{
    // Reset session globals (story/chunk/bg/chart flags)
    scr_reset_play_session();

    // High-level state
    global.GAME_STATE = "menu";
    global.in_menu = true;
    global.in_loading = false;
    global.play_requested = false;

    // Kill pause / editor / playback hybrid states
    global.GAME_PAUSED = false;
    global.editor_on = false;
    global.song_playing = false;
    global.pause_song_time = 0.0;

    // Stop all audio so nothing leaks
    audio_stop_all();

    // Invalidate handles so nothing resumes accidentally
    if (variable_global_exists("song_handle")) global.song_handle = -1;
    if (variable_global_exists("boss_handle")) global.boss_handle = -1;
    if (variable_global_exists("menu_music_handle")) global.menu_music_handle = -1;

    // Clear active player reference
    global.player = noone;

    // --- DESTROY gameplay-only controllers if they are persistent ---
    if (object_exists(obj_chunk_manager)) with (obj_chunk_manager) instance_destroy();
    if (object_exists(obj_pause_menu))    with (obj_pause_menu) instance_destroy();
    if (object_exists(obj_camera))        with (obj_camera) instance_destroy();

    // CRITICAL: obj_game is persistent in your project.
    // If we don't destroy it, Create won't run next time -> story won't reset.
    if (object_exists(obj_game)) with (obj_game) instance_destroy();

    // Turn off debug overlays (if you use these flags)
    if (variable_global_exists("dbg_marker_keys_on")) global.dbg_marker_keys_on = false;
    if (variable_global_exists("dbg_chunk_on")) global.dbg_chunk_on = false;
    if (variable_global_exists("dbg_lanes_on")) global.dbg_lanes_on = false;
    if (variable_global_exists("dbg_hitline_on")) global.dbg_hitline_on = false;
    if (variable_global_exists("dbg_chart_on")) global.dbg_chart_on = false;

    room_goto(rm_menu);
}
