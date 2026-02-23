/// obj_game : Create

// Only initialize once (obj_boot already does this)
if (!variable_global_exists("BOOT_DONE") || !global.BOOT_DONE)
{
    scr_globals_init();
    scr_input_init();
    scr_chunk_system_init();

    // Generic level init (no Level 3 hardcode)
    if (script_exists(scr_level_prepare_for_room)) scr_level_prepare_for_room(room);
    else scr_level_master_sections_init();

    scr_chunk_build_section_sequences();
    scr_phrases_load();
}
else
{
    if (script_exists(scr_input_init)) scr_input_init();

    // IMPORTANT: refresh level context when entering a different level room
    if (script_exists(scr_level_prepare_for_room)) scr_level_prepare_for_room(room);
}

global.force_chunk_refresh = true;
global.bg_repaint_all = true;

// --------------------------------------------------
// Determine difficulty (do NOT force normal)
// --------------------------------------------------
var d_boot = "normal";
if (variable_global_exists("DIFFICULTY")) d_boot = string_lower(string(global.DIFFICULTY));
else if (variable_global_exists("difficulty")) d_boot = string_lower(string(global.difficulty));
if (d_boot != "easy" && d_boot != "normal" && d_boot != "hard") d_boot = "normal";

// Apply difficulty (sets globals + sets chart_file from DIFF_CHART)
if (script_exists(scr_apply_difficulty)) scr_apply_difficulty(d_boot, "boot");

// Boss override last (if you use it)
if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss")
{
    global.chart_file = global.BOSS_CHART_FILE;
}

show_debug_message("[obj_game] level_key=" + string(global.LEVEL_KEY) + " difficulty=" + string(d_boot) + " chart_file=" + string(global.chart_file));

// Load chart
if (script_exists(scr_chart_load)) scr_chart_load();

// Prewarm BG textures so first frame swaps don't hitch mid-run
if (script_exists(scr_bg_prewarm_textures)) scr_bg_prewarm_textures();
if (script_exists(scr_tileset_prewarm_textures)) scr_tileset_prewarm_textures();

// Only init chunk/tile stuff for main mode rooms
if (!(variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss"))
{
    scr_chunk_system_init();
    if (script_exists(scr_level_prepare_for_room)) scr_level_prepare_for_room(room);
    scr_chunk_build_section_sequences();
}

scr_input_init();
scr_phrases_load();

// ===== World scroll speed (pixels per second) =====
global.WORLD_PPS = 448;

// Transport defaults
global.song_playing = false;
global.song_handle = -1;

// Level01 Hard: wrap tile layer draw with shader
if (room == rm_level01) {
    var lid = layer_get_id("TL_Visual_Hard");
    if (lid != -1) {
        layer_script_begin(lid, scr_fx_level01_hard_begin);
        layer_script_end(lid,   scr_fx_level01_hard_end);

        // IMPORTANT: do NOT use layer_shader at the same time
        layer_shader(lid, -1);
    }
}
if (!variable_global_exists("editor_time")) global.editor_time = 0;

// START_AT_S logic (kept as-is)
if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss") {
    global.editor_on = true;
    global.editor_time = 0.0;
    if (variable_global_exists("transport_time_s")) global.transport_time_s = 0.0;
    start_time_pending = false;
    if (script_exists(scr_story_seek_time)) scr_story_seek_time(0.0);
} else {
    global.editor_on = true;
    if (!variable_global_exists("START_AT_S")) global.START_AT_S = 0;
    start_time_pending = true;
}

// FAR
var bg_far = instance_create_layer(0, 0, "Instances", obj_bg_manager);
bg_far.bg_profile   = "far";
bg_far.parallax     = 0.35;
bg_far.fade_s       = 0.20;
bg_far.target_depth = 12000;
scr_bg_manager_apply_profile(bg_far);

// NEAR
var bg_near = instance_create_layer(0, 0, "Instances", obj_bg_manager);
bg_near.bg_profile   = "near";
bg_near.parallax     = 0.85;
bg_near.fade_s       = 0.15;
bg_near.target_depth = 11000;
scr_bg_manager_apply_profile(bg_near);

if (!variable_global_exists("fmod_inited") || !global.fmod_inited) {
    if (script_exists(scr_fmod_init)) scr_fmod_init();
}
if (script_exists(scr_fmod_debug_probe)) scr_fmod_debug_probe();
if (script_exists(scr_audio_route_apply)) scr_audio_route_apply();
if (!variable_global_exists("__last_room")) global.__last_room = room;
global.audio_last_room = room;
