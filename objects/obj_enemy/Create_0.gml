/// obj_enemy : Create

// IMPORTANT:
// This object may be created, then configured by obj_enemy_manager AFTER creation.
// Since Create runs first, we must set safe defaults and NEVER read unset vars here.

// --- Safe defaults (prevents "not set before reading") ---
t_anchor   = scr_chart_time(); // fallback anchor time
margin_px  = 0;
lane       = 0;
enemy_kind = 0;
y_gui      = -1;

// combat defaults
hp_max = 1;
hp     = hp_max;

// optional cached screen x (do NOT compute it here)
xg = 0;

// If your object uses any of these elsewhere, default them too:
dead = false;