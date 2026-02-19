/// scr_reset_play_session()
/// Clears cached session state so a new run starts clean (including story markers).

function scr_reset_play_session()
{
    // New run marker
    if (!variable_global_exists("run_id")) global.run_id = 0;
    global.run_id += 1;

    // Stop playback flags that can affect streaming
    global.song_playing    = false;
    global.pause_song_time = 0.0;
    global.GAME_PAUSED     = false;

    // Clear references
    global.player = noone;

    // -------------------------
    // STORY / MARKERS RESET
    // -------------------------
    global.STORY_PAUSED = false;
    global.story_state  = "idle";
    global.story_timer  = 0.0;

    global.story_pause_song_t      = 0.0;
    global.story_song_was_playing  = false;

    global.story_choice_active     = false;
    global.story_choice_caption    = "";
    global.story_choice_options    = [];
    global.story_choice_sel        = 0;

    global.story_choice_last       = "";
    global.story_choice_last_idx   = -1;

    // Stop any NPC audio handle
    if (variable_global_exists("story_npc_handle") && global.story_npc_handle >= 0) {
        audio_stop_sound(global.story_npc_handle);
        global.story_npc_handle = -1;
    }

    // Rebuild story events from markers (done=false)
    if (script_exists(scr_story_events_from_markers)) {
        scr_story_events_from_markers();
    } else {
        global.story_events = [];
    }

    global.story_idx = 0;

    // Also ensure "seek" state is clean at time 0
    if (script_exists(scr_story_seek_time)) scr_story_seek_time(0.0);

    // -------------------------
    // CHART RESET
    // Note: obj_game is persistent; it won't re-run Create() on restart.
    // scr_restart_level() is responsible for reloading chart after this clear.
    // -------------------------
    global.chart = [];
    global.chart_loaded_path = "";

    // ---- DESTROY persistent streaming/background controllers ----
    if (object_exists(obj_chunk_manager)) with (obj_chunk_manager) instance_destroy();
    if (object_exists(obj_bg_manager))    with (obj_bg_manager)    instance_destroy();

    // ---- CLEAR cached globals used by chunk/background selection ----
    if (variable_global_exists("chunk_cache_ready")) global.chunk_cache_ready = false;
    if (variable_global_exists("bg_cache_ready"))    global.bg_cache_ready    = false;

    if (variable_global_exists("chunk_seed")) global.chunk_seed = -1;
    if (variable_global_exists("chunk_rng"))  global.chunk_rng  = -1;

    if (variable_global_exists("difficulty_name")) global.difficulty_name = "";
}