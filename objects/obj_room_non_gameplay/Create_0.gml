/// obj_room_non_gameplay : Create
// Flag-style globals (safe even if unused elsewhere)
global.GAME_STATE = "menu";   // NOT "play"
global.GAME_PAUSED = false;

// If your game has any gameplay-only systems that auto-start,
// force them off here (guards so it won’t error if missing).
if (variable_global_exists("EDITOR_ON")) global.EDITOR_ON = false;
