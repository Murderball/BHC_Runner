/// obj_player_spawner : Create
/// Canonical mapping: 0=vocals, 1=guitar, 2=bass, 3=drums
/// Spawns selected player and lets scr_player_snap_to_spawn() handle final Y

// ------------------------------------------------------------
// IMPORTANT: Upgrade room should NOT spawn the runner player.
// rm_upgrade uses its own preview object instead.
// ------------------------------------------------------------
if (room_get_name(room) == "rm_upgrade")
{
    instance_destroy();
    exit;
}

// Safety: some projects use a flag too
if (variable_global_exists("in_upgrade") && global.in_upgrade)
{
    instance_destroy();
    exit;
}

// ------------------------------------------------------------
// Normal game spawn behavior
// ------------------------------------------------------------
if (!variable_global_exists("char_id")) global.char_id = 0;
global.char_id = clamp(real(global.char_id), 0, 3);

var sx = x;
var sy = y;

// Pick object to spawn (default safe)
var obj_to_spawn = obj_player_guitar;

switch (global.char_id)
{
    case 0: obj_to_spawn = obj_player_vocals; break;
    case 1: obj_to_spawn = obj_player_guitar; break;
    case 2: obj_to_spawn = obj_player_bass;   break;
    case 3: obj_to_spawn = obj_player_drums;  break;
}

// Spawn on same layer as spawner (safe)
var p = instance_create_layer(sx, sy, layer, obj_to_spawn);

// Force X to hitline in world-space (348 screen px from left edge)
if (variable_global_exists("player_screen_x"))
{
    var cam = view_camera[0];
    var camx = camera_get_view_x(cam);
    p.x = camx + global.player_screen_x;
}

// Safety: if spawn failed, don't proceed
if (p == noone)
{
    show_debug_message("SPAWNER: FAILED to spawn player (noone).");
    instance_destroy();
    exit;
}

// Register as the active player
global.player = p;
p.char_id = global.char_id;

// Reset animation/state so a new run doesn't inherit paused anim state
if (variable_instance_exists(p, "image_index")) p.image_index = 0;
if (variable_instance_exists(p, "image_speed")) p.image_speed = 1;

if (variable_instance_exists(p, "atk_state")) p.atk_state = 0;
if (variable_instance_exists(p, "atk_timer")) p.atk_timer = 0;
if (variable_instance_exists(p, "atk_cooldown")) p.atk_cooldown = 0;
if (variable_instance_exists(p, "atk1_lock")) p.atk1_lock = false;

if (variable_instance_exists(p, "vsp")) p.vsp = 0;
if (variable_instance_exists(p, "hsp")) p.hsp = 0;
if (variable_instance_exists(p, "grounded")) p.grounded = false;

if (!variable_global_exists("player_world_y")) global.player_world_y = p.y;

// Let your existing snap system do the final placement using scr_solid_at + player_world_y
if (script_exists(scr_player_snap_to_spawn))
{
    script_execute(scr_player_snap_to_spawn);
}

instance_destroy();
