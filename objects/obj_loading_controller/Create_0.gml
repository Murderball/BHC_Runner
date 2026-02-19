/// obj_loading_controller : Create

if (!variable_global_exists("next_room")) global.next_room = rm_menu;
global.in_loading = true;

// ----------------------------------------
// RANDOM LOADING BACKGROUND (6 total)
// ----------------------------------------
// RENAME THESE STRINGS TO YOUR ACTUAL SPRITE NAMES
loading_bgs = [
    asset_get_index("spr_loading_bg_0"),
    asset_get_index("spr_loading_bg_1"),
    asset_get_index("spr_loading_bg_2"),
    asset_get_index("spr_loading_bg_3"),
    asset_get_index("spr_loading_bg_4"),
    asset_get_index("spr_loading_bg_5")
];

// Pick ONE random valid background
bg_i = -1;
var n = array_length(loading_bgs);

if (n > 0)
{
    var tries = 0;
    while (tries < n)
    {
        var r = irandom(n - 1);
        if (loading_bgs[r] >= 0) { bg_i = r; break; }
        tries++;
    }
    if (bg_i < 0) bg_i = 0;
}

// ----------------------------------------
// Timing
// ----------------------------------------
load_timer_ms = 1500;   // minimum time the loading screen stays
last_ms = current_time;

// ----------------------------------------
// Fade-in + Slow Zoom
// ----------------------------------------
fade_in_ms = 450;       // fade from black duration
fade_accum_ms = 0;

zoom_start = 1.00;
zoom_end   = 1.03;      // subtle zoom
zoom_ms    = 5000;      // how long it takes to reach zoom_end
zoom_accum_ms = 0;

// Optional: different random zoom direction (tiny pan)
pan_strength = 18;      // pixels of drift at full zoom time (0 to disable)
pan_x = irandom_range(-pan_strength, pan_strength);
pan_y = irandom_range(-pan_strength, pan_strength);
