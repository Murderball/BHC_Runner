/// obj_game : Step Event
if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED) exit;
if (!variable_instance_exists(id, "duck_timer")) duck_timer = 0;
if (duck_timer > 0) duck_timer--;

// --------------------------------------------------
// HARD GUARDS: do not run gameplay flow in menu/loading
// --------------------------------------------------
if (room == rm_menu) {
    if (instance_exists(obj_input_recorder_machine)) with (obj_input_recorder_machine) instance_destroy();
    if (variable_global_exists("in_menu")) global.in_menu = true;
    if (variable_global_exists("editor_on")) global.editor_on = false;
    exit;
}

if (room == rm_loading) {
    if (instance_exists(obj_input_recorder_machine)) with (obj_input_recorder_machine) instance_destroy();
    // Let rm_loading display for at least a few frames
    exit;
}

if (variable_global_exists("in_loading") && global.in_loading) {
    // If some persistent logic runs during loading, don't allow redirects
    exit;
}

// ================= STARTUP LOADING GATE =================
// Purpose: do heavy startup work (chart load / refresh) BEFORE gameplay begins,
// so the "139ms" hitch doesn't happen mid-run.
if (variable_global_exists("STARTUP_LOADING") && global.STARTUP_LOADING)
{
    // Force ONE full refresh while we're still "loading"
    global.force_chunk_refresh = true;
    global.bg_repaint_all = true;

    // Wait a couple frames so tilemaps/background settle visually
    global.startup_frames_left -= 1;

    if (global.startup_frames_left <= 0)
    {
        global.STARTUP_LOADING = false;
    }

    // IMPORTANT: skip the rest of Step while loading
    exit;
}


// Input recorder manager (authoritative recorder)
if (!instance_exists(obj_input_recorder_machine)) {
    instance_create_layer(0, 0, "Instances", obj_input_recorder_machine);
}

// --------------------------------------------------
// F12: Toggle window between monitor 1 and monitor 2
// --------------------------------------------------
if (keyboard_check_pressed(vk_f12))
{
    if (os_type == os_windows)
    {
        window_set_fullscreen(false);

        // Flip state
        global.win_on_second = !global.win_on_second;

        // Size first (more reliable)
        window_set_size(global.win_default_w, global.win_default_h);

        if (global.win_on_second)
        {
            // Move to monitor 2 (assumes monitor 2 is to the RIGHT)
            var desktop_w = display_get_width();
            var primary_w = desktop_w div 2;

            window_set_position(primary_w + global.win_m2_pad_x, global.win_m2_pad_y);
        }
        else
        {
            // Move to monitor 1
            window_set_position(global.win_m1_x, global.win_m1_y);
        }

        display_set_gui_size(global.win_default_w, global.win_default_h);
    }
}

// ========================================================
// Apply deferred start time once everything is initialized
// FIX: Don't do an audible seek-to-zero after the song already started.
if (start_time_pending) {
    start_time_pending = false;

    var t0 = 0.0;
    if (variable_global_exists("START_AT_S")) t0 = real(global.START_AT_S);

    // Only seek if it's meaningfully non-zero (editor/testing jump)
    // This prevents the "plays a split second then restarts" hiccup.
    if (t0 > 0.001) {
        scr_set_playhead_time(t0);
    }
}

// --------------------------------------------------------------------
// Boss trigger (MUST run every frame during gameplay)
// --------------------------------------------------------------------
if (!global.editor_on && global.LEVEL_MODE == "main")
{
    var t = scr_song_time();

    // If audio ended, force boss start too (covers short/trimmed exports)
    var audio_ended = false;
    if (global.song_handle >= 0) {
        audio_ended = false;
    }

    if (t >= global.BOSS_TRIGGER_S || audio_ended) {
        scr_start_boss_level();
        exit;
    }
}

scr_autoplay_update();

// Gameplay-only controls
if (!global.editor_on) {
    // TODO: controller gameplay
}
