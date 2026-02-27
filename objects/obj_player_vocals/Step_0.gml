/// obj_player_vocals : Step
/// Crash-proof: editor_on + input globals may not exist yet
/// Jump/Duck/Physics + placeholder guitar projectile attacks
/// Duck anim plays once then holds last frame (wrap-proof)
/// Stable collision mask to prevent falling through while ducking

if (menu_preview)
{
    y += sin(current_time * 0.006) * 0.1;
    exit;
}
// ----------------------------------------------------
// FREE MOVE (NON-GAMEPLAY ROOMS ONLY)
// ----------------------------------------------------
if (script_exists(scr_player_free_move_update))
{
    if (scr_player_free_move_update(8)) exit;
}

// ----------------------------------------------------
// Safe globals (may not exist yet)
// ----------------------------------------------------
var editor_on = variable_global_exists("editor_on") ? global.editor_on : false;

var paused = false;
if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED) paused = true;
if (variable_global_exists("STORY_PAUSED") && global.STORY_PAUSED) paused = true;

// Attack flash decay (seconds)
var denom_flash = game_get_speed(gamespeed_fps);
if (denom_flash == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_flash = 1;
}
atk_flash_t = max(0, atk_flash_t - (1 / denom_flash));

// Inputs (default false if not set yet)
var in_jump = variable_global_exists("in_jump") ? global.in_jump : false;
var in_duck = variable_global_exists("in_duck") ? global.in_duck : false;
var in_atk1 = variable_global_exists("in_atk1") ? global.in_atk1 : false;
var in_atk2 = variable_global_exists("in_atk2") ? global.in_atk2 : false;
var in_atk3 = variable_global_exists("in_atk3") ? global.in_atk3 : false;
var in_ult  = variable_global_exists("in_ult")  ? global.in_ult  : false;

var hold_duck = variable_global_exists("hold_duck") ? global.hold_duck : false;

// Action ids (optional; if missing, we still perform action but skip judging)
var has_ACT = variable_global_exists("ACT_JUMP");
var ACT_JUMP = has_ACT ? global.ACT_JUMP : -1;
var ACT_DUCK = variable_global_exists("ACT_DUCK") ? global.ACT_DUCK : -1;
var ACT_ATK1 = variable_global_exists("ACT_ATK1") ? global.ACT_ATK1 : -1;
var ACT_ATK2 = variable_global_exists("ACT_ATK2") ? global.ACT_ATK2 : -1;
var ACT_ATK3 = variable_global_exists("ACT_ATK3") ? global.ACT_ATK3 : -1;
var ACT_ULT  = variable_global_exists("ACT_ULT")  ? global.ACT_ULT  : -1;

var cam = view_camera[0];
x = camera_get_view_x(cam) + player_screen_x;

// ----------------------------------------------------
// Stable collision mask
// ----------------------------------------------------
if (!is_undefined(SPR_IDLE) && SPR_IDLE != 0) {
    if (mask_index != SPR_IDLE) mask_index = SPR_IDLE;
} else {
    if (mask_index != spr_vocalist_idle) mask_index = spr_vocalist_idle;
}

// ----------------------------------------------------
// Duck loop tracking
// ----------------------------------------------------
if (!variable_instance_exists(id, "duck_prev_index")) duck_prev_index = 0;

// ----------------------------------------------------
// Spawn init
// ----------------------------------------------------
if (just_spawned)
{
    hsp = 0; vsp = 0; grounded = true;
    duck_timer = 0;

    anim_lock = 0;
    anim_lock_state = "idle";
    set_state("idle");

    image_index = 0;
    image_speed = 1;

    if (script_exists(scr_player_snap_to_spawn)) script_execute(scr_player_snap_to_spawn);
    just_spawned = false;
}

// ----------------------------------------------------
// Editor transitions (SAFE)
// ----------------------------------------------------
if (!prev_editor_on && editor_on)
{
    hsp = 0; vsp = 0; grounded = true;
    duck_timer = 0;

    anim_lock = 0;
    anim_lock_state = "idle";
    set_state("idle");

    image_index = 0;
    image_speed = 1;

    if (!variable_instance_exists(id, "player_world_y")) player_world_y = y;
    spawn_y = player_world_y;
    y = spawn_y;

    if (script_exists(scr_player_snap_to_spawn)) script_execute(scr_player_snap_to_spawn);
}

if (prev_editor_on && !editor_on)
{
    if (!variable_instance_exists(id, "player_world_y")) player_world_y = y;

    spawn_y = player_world_y;
    y = spawn_y;

    if (script_exists(scr_player_snap_to_spawn)) script_execute(scr_player_snap_to_spawn);

    grounded = true;
    vsp = 0;
    hsp = 0;

    duck_timer = 0;

    anim_lock = 0;
    anim_lock_state = "run";
    set_state("run");

    image_speed = 1;
}

// ----------------------------------------------------
// Config
// ----------------------------------------------------
var grav   = 4;
var jump_v = -60;

// ----------------------------------------------------
// Paused: freeze + idle
// ----------------------------------------------------
if (paused)
{
    hsp = 0; vsp = 0; grounded = true;
    duck_timer = 0;

    anim_lock = 0;
    anim_lock_state = "idle";
    set_state("idle");

    sprite_index = SPR_IDLE;
    image_speed = 1;

    prev_editor_on = editor_on;
    exit;
}

// ----------------------------------------------------
// Gameplay triggers (play only)
// ----------------------------------------------------
if (!editor_on)
{
    var _fps = max(1, game_get_speed(gamespeed_fps));
    var _dt_s = 1 / _fps;
    if (script_exists(scr_actions_update)) scr_actions_update(_dt_s);

    if (in_jump) {
        if (script_exists(scr_action_try)) scr_action_try(ACT.JUMP);
    }

    if (in_duck || hold_duck) {
        if (script_exists(scr_action_try)) scr_action_try(ACT.DUCK);
    }

    if (in_atk1) {
        if (script_exists(scr_action_try)) scr_action_try(ACT.ATK1);
    }

    if (in_atk2) {
        if (script_exists(scr_action_try)) scr_action_try(ACT.ATK2);
    }

    if (in_atk3) {
        if (script_exists(scr_action_try)) scr_action_try(ACT.ATK3);
    }

    if (global.in_ult || global.in_ult_manual) {
        if (script_exists(scr_action_try)) scr_action_try(ACT.ULT);
    }
}

if (!editor_on)
{
    vsp += grav;

    var result = scr_move_and_collide(hsp, vsp);
    hsp = result[0];
    vsp = result[1];

    var foot_x2 = (bbox_left + bbox_right) * 0.5;
    grounded = scr_solid_at(foot_x2, bbox_bottom + 1);
}

// ----------------------------------------------------
// State resolution
// ----------------------------------------------------
if (editor_on)
{
    anim_lock = 0;
    anim_lock_state = "idle";
    set_state("idle");
}
else
{
    if (anim_lock > 0)
    {
        anim_lock -= 1;
        if (anim_lock_state == "attack") set_state("run");
        else if (state != anim_lock_state) set_state(anim_lock_state);
    }
    else
    {
        if (duck_timer > 0) set_state("duck");
        else if (!grounded && vsp < -1) set_state("jump");
        else set_state("run");
    }
}

// ----------------------------------------------------
// Apply sprite
// ----------------------------------------------------
if (is_undefined(SPR_IDLE) || SPR_IDLE == 0) SPR_IDLE = spr_vocalist_idle;
if (is_undefined(SPR_RUN)  || SPR_RUN  == 0) SPR_RUN  = spr_vocalist_run;
if (is_undefined(SPR_JUMP) || SPR_JUMP == 0) SPR_JUMP = spr_vocalist_jump;
if (is_undefined(SPR_DUCK) || SPR_DUCK == 0) SPR_DUCK = spr_vocalist_duck;

switch (state)
{
    case "idle": sprite_index = SPR_IDLE; break;
    case "run":  sprite_index = SPR_RUN;  break;
    case "jump": sprite_index = SPR_JUMP; break;
    case "duck": sprite_index = SPR_DUCK; break;
    default:     sprite_index = SPR_RUN;  break;
}

// ----------------------------------------------------
// NON-LOOP DUCK (wrap-proof)
// ----------------------------------------------------
if (state == "duck")
{
    if (image_index < duck_prev_index || image_index >= image_number - 1)
    {
        image_index = image_number - 1;
        image_speed = 0;
    }
    else image_speed = 1;

    duck_prev_index = image_index;
}
else
{
    duck_prev_index = 0;
    image_speed = 1;
}

prev_editor_on = editor_on;
