/// obj_enemy : Step
if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED) exit;

// Enemies are GUI-timeline driven.
// No window-time logic required.
// Cull handled in Draw GUI.

if (dead) exit;
