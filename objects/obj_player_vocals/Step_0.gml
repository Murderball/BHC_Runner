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
atk_flash_t = max(0, atk_flash_t - (1 / room_speed));

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

    if (script_exists(scr_player_snap_to_spawn)) scr_player_snap_to_spawn();
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

    if (script_exists(scr_player_snap_to_spawn)) scr_player_snap_to_spawn();
}

if (prev_editor_on && !editor_on)
{
    if (!variable_instance_exists(id, "player_world_y")) player_world_y = y;

    spawn_y = player_world_y;
    y = spawn_y;

    if (script_exists(scr_player_snap_to_spawn)) scr_player_snap_to_spawn();

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
    duck_timer = max(0, duck_timer - 1);

    var was_grounded = grounded;
    var foot_x = (bbox_left + bbox_right) * 0.5;
    var grounded_now = scr_solid_at(foot_x, bbox_bottom + 1);
    var can_jump = was_grounded || grounded_now;

    // Jump
    if (in_jump && can_jump)
    {
        if (ACT_JUMP != -1)
        {
            var judgeJ = scr_try_trigger(ACT_JUMP);
            global.last_jump_judge = judgeJ;
            if (judgeJ != "miss") scr_perf_grade(judgeJ);
        }

        if (script_exists(scr_player_unstick_y)) scr_player_unstick_y(id);
        vsp = jump_v;
        grounded = false;

        lock_anim("jump", ceil(room_speed * 0.10));
    }

    // Duck hold
    if (in_duck || hold_duck)
    {
        if (in_duck && ACT_DUCK != -1)
        {
            var judgeD = scr_try_trigger(ACT_DUCK);
            global.last_duck_judge = judgeD;
            if (judgeD != "miss") scr_perf_grade(judgeD);
        }
        duck_timer = max(duck_timer, ceil(room_speed * 0.20));
    }

    // --- ATK1 ---
    if (in_atk1)
    {
        if (ACT_ATK1 != -1)
        {
            var judgeA1 = scr_try_trigger(ACT_ATK1);
            global.last_atk1_judge = judgeA1;
            if (judgeA1 != "miss") {
                scr_perf_grade(judgeA1);
                atk_flash_t = 0.12;
                atk_flash_color = c_black;
            }
        }
        else
        {
            // no ACT ids yet - still allow attack for testing
        }

        lock_anim("attack", ceil(room_speed * 0.15));

        var dmg1 = 1;

        var cam_x = camera_get_view_x(cam);
        var cam_y = camera_get_view_y(cam);

        var zoom = 1.0;
        if (instance_exists(obj_camera) && variable_instance_exists(obj_camera, "cam_zoom")) zoom = obj_camera.cam_zoom;

		// Fire point in ROOM space, anchored to bbox (origin-safe)
		var fire_x_room = bbox_left + 24;
		var fire_y_room = bbox_top  + 75;

		// Convert to GUI space
		var ox = (fire_x_room - cam_x) * zoom;
		var oy = (fire_y_room - cam_y) * zoom;

        var tgt = scr_find_nearest_enemy_gui(ox, oy, 2500);

        var dir = 0;
        if (instance_exists(tgt))
        {
            var tp = scr_enemy_gui_pos(tgt);
            dir = point_direction(ox, oy, tp.x, tp.y);
        }

		var p = instance_create_layer(fire_x_room, fire_y_room, "Instances", obj_proj_guitar);
        p.gui_x = ox; p.gui_y = oy;
        p.target = tgt; p.homing = instance_exists(tgt);

        var spd = 900;
        p.speed_gui = spd;
        p.gui_vx = lengthdir_x(spd, dir);
        p.gui_vy = lengthdir_y(spd, dir);
        p.dir = dir;

        p.damage = dmg1;
        p.life_max = 1.2;
        p.proj_act = "atk1";
        p.proj_color = c_aqua;
    }

    // --- ATK2 ---
    if (in_atk2)
    {
        if (ACT_ATK2 != -1)
        {
            var judgeA2 = scr_try_trigger(ACT_ATK2);
            global.last_atk2_judge = judgeA2;
            if (judgeA2 != "miss") {
                scr_perf_grade(judgeA2);
                atk_flash_t = 0.14;
                atk_flash_color = script_exists(scr_note_draw_color) ? scr_note_draw_color(ACT_ATK2) : make_color_rgb(0, 200, 255);
            }
        }

        lock_anim("attack", ceil(room_speed * 0.15));

        var dmg2 = 2;

        var cam_x2 = camera_get_view_x(cam);
        var cam_y2 = camera_get_view_y(cam);

        var zoom2 = 1.0;
        if (instance_exists(obj_camera) && variable_instance_exists(obj_camera, "cam_zoom")) zoom2 = obj_camera.cam_zoom;



		var fire_x_room2 = bbox_left + 24;
		var fire_y_room2 = bbox_top  + 75;

		var ox2 = (fire_x_room2 - cam_x2) * zoom2;
		var oy2 = (fire_y_room2 - cam_y2) * zoom2;

        var tgt2 = scr_find_nearest_enemy_gui(ox2, oy2, 2500);

        var dir2 = 0;
        if (instance_exists(tgt2))
        {
            var tp2 = scr_enemy_gui_pos(tgt2);
            dir2 = point_direction(ox2, oy2, tp2.x, tp2.y);
        }

		var p2 = instance_create_layer(fire_x_room2, fire_y_room2, "Instances", obj_proj_guitar);;
        p2.gui_x = ox2; p2.gui_y = oy2;
        p2.target = tgt2; p2.homing = instance_exists(tgt2);

        var spd2 = 1050;
        p2.speed_gui = spd2;
        p2.gui_vx = lengthdir_x(spd2, dir2);
        p2.gui_vy = lengthdir_y(spd2, dir2);
        p2.dir = dir2;

        p2.damage = dmg2;
        p2.life_max = 1.2;
        p2.pierce = true;
        p2.proj_act = "atk2";
        p2.proj_color = script_exists(scr_note_draw_color) ? scr_note_draw_color(p2.proj_act) : make_color_rgb(0, 200, 255);
    }

    // --- ATK3 ---
    if (in_atk3)
    {
        if (ACT_ATK3 != -1)
        {
            var judgeA3 = scr_try_trigger(ACT_ATK3);
            global.last_atk3_judge = judgeA3;
            if (judgeA3 != "miss") {
                scr_perf_grade(judgeA3);
                atk_flash_t = 0.16;
                atk_flash_color = script_exists(scr_note_draw_color) ? scr_note_draw_color(ACT_ATK3) : make_color_rgb(190, 95, 255);
            }
        }

        lock_anim("attack", ceil(room_speed * 0.15));

        var dmg3 = 3;

        var cam_x3 = camera_get_view_x(cam);
        var cam_y3 = camera_get_view_y(cam);

        var zoom3 = 1.0;
        if (instance_exists(obj_camera) && variable_instance_exists(obj_camera, "cam_zoom")) zoom3 = obj_camera.cam_zoom;


		var fire_x_room3 = bbox_left + 24;
		var fire_y_room3 = bbox_top  + 75;

		var ox3 = (fire_x_room3 - cam_x3) * zoom3;
		var oy3 = (fire_y_room3 - cam_y3) * zoom3;

        var tgt3 = scr_find_nearest_enemy_gui(ox3, oy3, 2500);

        var dir3 = 0;
        if (instance_exists(tgt3))
        {
            var tp3 = scr_enemy_gui_pos(tgt3);
            dir3 = point_direction(ox3, oy3, tp3.x, tp3.y);
        }

		var p3 = instance_create_layer(fire_x_room3, fire_y_room3, "Instances", obj_proj_guitar);;
        p3.gui_x = ox3; p3.gui_y = oy3;
        p3.target = tgt3; p3.homing = instance_exists(tgt3);

        var spd3 = 850;
        p3.speed_gui = spd3;
        p3.gui_vx = lengthdir_x(spd3, dir3);
        p3.gui_vy = lengthdir_y(spd3, dir3);
        p3.dir = dir3;

        p3.damage = dmg3;
        p3.life_max = 1.4;
        p3.hit_radius = 22;
        p3.proj_act = "atk3";
        p3.proj_color = script_exists(scr_note_draw_color) ? scr_note_draw_color(p3.proj_act) : make_color_rgb(190, 95, 255);
    }

// --- ULT (manual OR note-triggered) ---
    if (global.in_ult || global.in_ult_manual)
    {
        var judgeU = "miss";

        // If we actually have an ult note in-window, grade it normally
        if (global.in_ult)
        {
            judgeU = scr_try_trigger(global.ACT_ULT);
        }

        // If manual ult was pressed and there was no ult note, still fire (baseline)
        if (judgeU == "miss" && global.in_ult_manual)
        {
            judgeU = "good";
        }

        global.last_ult_judge = judgeU;

        if (judgeU != "miss")
        {
            scr_perf_grade(judgeU);
            atk_flash_t = 0.20;
            atk_flash_color = script_exists(scr_note_draw_color) ? scr_note_draw_color(ACT_ULT) : make_color_rgb(255, 170, 40);
            if (script_exists(scr_player_ultimate_guitar)) scr_player_ultimate_guitar(id, judgeU);
        }
    }
}

// ----------------------------------------------------
// Physics
// ----------------------------------------------------
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
