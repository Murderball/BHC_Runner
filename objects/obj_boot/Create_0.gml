/// obj_bootstrap : Create

// Run once, ever
if (variable_global_exists("BOOT_DONE") && global.BOOT_DONE)
{
    instance_destroy();
    exit;
}
global.BOOT_DONE = true;

// Ensure folders exist BEFORE loading anything that might use them
if (!directory_exists("charts")) directory_create("charts");

// Default level key if not set by menu yet
if (!variable_global_exists("LEVEL_KEY") || !is_string(global.LEVEL_KEY) || global.LEVEL_KEY == "")
{
    global.LEVEL_KEY = "level03";
}

// 1) Init globals (must define ALL globals read anywhere)
scr_globals_init();

// 1.5) Load persistent audio settings and apply to master output
scr_audio_settings_load();
scr_audio_settings_apply();

// 2) Init subsystems in a known order
scr_input_init();
scr_chunk_system_init();
scr_level_master_sections_init(global.LEVEL_KEY);
scr_chunk_build_section_sequences();

// 3) Load data AFTER defaults set
scr_chart_load();
scr_phrases_load();

// Application surface must remain enabled for normal gameplay rendering.
application_surface_enable(true);
application_surface_draw_enable(true);

// Explicitly do not spawn post FX compositor.

// Done
instance_destroy();
