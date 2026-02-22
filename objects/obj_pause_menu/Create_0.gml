/// obj_pause_menu : Create

paused = false;

// Labels (only used for debug / fallback)
items = ["RESUME", "RESTART LEVEL", "GAME", "TITLE MENU", "EXIT GAME"];
sel = 0;

// repeat control
move_cd = 0;

// ----------------------------------
// Keyboard-selection dashed outline
// ----------------------------------
kb_nav_timer = 0;     // >0 means "keyboard is being used"
kb_dash_phase = 0;    // marching ants phase

// ----------------------------------
// Mouse hover glow
// ----------------------------------
glow = [];
for (var i = 0; i < array_length(items); i++) glow[i] = 0;
glow_speed = 0.22;

hover_i = -1;

// Button rect cache (GUI coords)
btn = [];

// ----------------------------------
// SPRITE BUTTONS (your assets)
// ----------------------------------
// NOTE: Add a sprite named "menu_restart" (recommended).
// If it doesn't exist yet, this will return -1 and simply not draw that button.
spr_items = [
    asset_get_index("menu_resume"),
    asset_get_index("menu_restart"),
    asset_get_index("menu_game"),
    asset_get_index("menu_main"),
    asset_get_index("menu_exit_game")
];

// optional scaling (if needed later)
spr_scale = 1.0;

if (spr_items[2] < 0) spr_items[2] = asset_get_index("menu_options");

menu_game_open = false;
menu_game_sel = 0;
menu_game_adjust = false;
menu_game_step = 0.05;
menu_game_slider_active = false;
menu_game_anchor_x = 0;
menu_game_anchor_y = 0;
menu_game_anchor_w = 0;
menu_game_anchor_h = 0;

options_panel_pad = 18;
options_panel_w = 380;
options_panel_h = 160;
options_panel_gap = 20;
options_panel_align_y = -12;
options_slider_drag = false;
options_slider_step = 0.05;
options_panel_x = 0;
options_panel_y = 0;
options_slider_min_x = 0;
options_slider_max_x = 0;
options_slider_y = 0;

// Global pause flag (if used elsewhere)
if (!variable_global_exists("GAME_PAUSED")) global.GAME_PAUSED = false;

// ------------------------
// Pause background "blur"
// ------------------------
blur_surf = -1;
blur_scale = 0.25;      // 0.20–0.33 = blurrier but softer
blur_alpha = 1.00;      // overall blurred background strength
blur_passes = 2;        // 1–3 (2 is a sweet spot)
blur_jitter = 1.5;      // subtle smear amount (0–3)
