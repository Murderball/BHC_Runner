/// obj_bg_manager : Create Event

// --- REQUIRED DEFAULTS (do NOT read vars until they exist) ---
if (!variable_instance_exists(id, "bg_profile")) bg_profile = "near";
if (!variable_instance_exists(id, "parallax"))   parallax   = 1.0;
if (!variable_instance_exists(id, "fade_s"))     fade_s     = 0.15;
if (!variable_instance_exists(id, "target_depth")) target_depth = undefined;

if (is_real(target_depth)) depth = target_depth;

// --- Ensure section data exists ---
scr_level_master_sections_init();
sections = global.master_sections;

// --- Map ---
bg_map = scr_bg_map_build(bg_profile);

// --- State ---
cur_i = 0;
prev_i = -1;
fade = 1.0;

cur_spr = -1;
prev_spr = -1;
