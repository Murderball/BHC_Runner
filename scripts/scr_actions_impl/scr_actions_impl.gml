function scr_action_apply_flash(_judge, _t, _col)
{
    if (_judge != "miss") {
        scr_perf_grade(_judge);
        atk_flash_t = _t;
        atk_flash_color = _col;
    }
}

function scr_action_spawn_projectile(_shooter, _act_name, _judge, _base_dmg, _spd, _life, _pierce, _hit_radius, _proj_col)
{
    var _dmg = _base_dmg;
    if (_judge == "perfect") _dmg = ceil(_base_dmg * 2);
    else if (_judge == "good") _dmg = max(1, _base_dmg + 1);

    var cam = view_camera[0];
    var cam_x = camera_get_view_x(cam);
    var cam_y = camera_get_view_y(cam);
    var zoom = 1.0;
    if (instance_exists(obj_camera) && variable_instance_exists(obj_camera, "cam_zoom")) zoom = obj_camera.cam_zoom;

    var fire_x_room;
    var fire_y_room;
    if (!instance_exists(_shooter)) return false;

    var has_bbox = variable_instance_exists(_shooter, "bbox_left")
        && variable_instance_exists(_shooter, "bbox_top")
        && variable_instance_exists(_shooter, "bbox_bottom");

    if (has_bbox) {
        fire_x_room = _shooter.bbox_left + 24;
        fire_y_room = _shooter.bbox_top + 75;
    } else {
        fire_x_room = _shooter.x;
        fire_y_room = _shooter.y;
    }

    var ox = (fire_x_room - cam_x) * zoom;
    var oy = (fire_y_room - cam_y) * zoom;
    var tgt = scr_find_nearest_enemy_gui(ox, oy, 2500);

    var dir = 0;
    if (instance_exists(tgt)) {
        var tp = scr_enemy_gui_pos(tgt);
        dir = point_direction(ox, oy, tp.x, tp.y);
    }

    var p = instance_create_layer(fire_x_room, fire_y_room, "Instances", obj_proj_guitar);
    p.gui_x = ox; p.gui_y = oy;
    p.target = tgt; p.homing = instance_exists(tgt);
    p.speed_gui = _spd;
    p.gui_vx = lengthdir_x(_spd, dir);
    p.gui_vy = lengthdir_y(_spd, dir);
    p.dir = dir;
    p.damage = _dmg;
    p.life_max = _life;
    if (_pierce) p.pierce = true;
    if (_hit_radius > 0) p.hit_radius = _hit_radius;
    p.proj_act = _act_name;
    p.proj_color = _proj_col;
    return true;
}

function scr_act_exec_jump(p, act, def)
{
    if (script_exists(scr_player_unstick_y)) scr_player_unstick_y(p.id);
    p.vsp = -60;
    p.grounded = false;
    if (variable_instance_exists(p, "lock_anim")) p.lock_anim("jump", ceil(game_get_speed(gamespeed_fps) * 0.10));
    var judge = scr_try_trigger(global.ACT_JUMP);
    global.last_jump_judge = judge;
    if (judge != "miss") scr_perf_grade(judge);
    return true;
}

function scr_act_exec_duck(p, act, def)
{
    p.duck_timer = max(p.duck_timer, ceil(game_get_speed(gamespeed_fps) * 0.20));
    if (global.in_duck) {
        var judge = scr_try_trigger(global.ACT_DUCK);
        global.last_duck_judge = judge;
        if (judge != "miss") scr_perf_grade(judge);
    }
    return true;
}

function scr_act_exec_atk1(p, act, def)
{
    var judge = scr_try_trigger(global.ACT_ATK1); global.last_atk1_judge = judge;
    scr_action_apply_flash(judge, 0.12, c_black);
    if (variable_instance_exists(p, "lock_anim")) p.lock_anim("attack", ceil(game_get_speed(gamespeed_fps) * 0.15));
    scr_action_spawn_projectile(p, "atk1", judge, 1, 900, 1.2, false, 0, c_aqua);
    return true;
}

function scr_act_exec_atk2(p, act, def)
{
    var judge = scr_try_trigger(global.ACT_ATK2); global.last_atk2_judge = judge;
    var col = script_exists(scr_note_draw_color) ? scr_note_draw_color(global.ACT_ATK2) : make_color_rgb(0, 200, 255);
    scr_action_apply_flash(judge, 0.14, col);
    if (variable_instance_exists(p, "lock_anim")) p.lock_anim("attack", ceil(game_get_speed(gamespeed_fps) * 0.15));
    scr_action_spawn_projectile(p, "atk2", judge, 2, 1050, 1.2, true, 0, col);
    return true;
}

function scr_act_exec_atk3(p, act, def)
{
    var judge = scr_try_trigger(global.ACT_ATK3); global.last_atk3_judge = judge;
    var col = script_exists(scr_note_draw_color) ? scr_note_draw_color(global.ACT_ATK3) : make_color_rgb(190, 95, 255);
    scr_action_apply_flash(judge, 0.16, col);
    if (variable_instance_exists(p, "lock_anim")) p.lock_anim("attack", ceil(game_get_speed(gamespeed_fps) * 0.15));
    scr_action_spawn_projectile(p, "atk3", judge, 3, 850, 1.4, false, 22, col);
    return true;
}

function scr_act_exec_ult(p, act, def)
{
    var judge = "miss";
    if (global.in_ult) judge = scr_try_trigger(global.ACT_ULT);
    if (judge == "miss" && global.in_ult_manual) judge = "good";
    global.last_ult_judge = judge;
    if (judge == "miss") return false;
    var col = script_exists(scr_note_draw_color) ? scr_note_draw_color(global.ACT_ULT) : make_color_rgb(255, 170, 40);
    scr_action_apply_flash(judge, 0.20, col);
    // Adapter: use existing ultimate implementation.
    if (script_exists(scr_player_ultimate_guitar)) scr_player_ultimate_guitar(p.id, judge);
    return true;
}

function scr_action_name(char_id, act_id)
{
    if (!variable_global_exists("actions_inited") || !global.actions_inited) return "";
    return global.action_defs[char_id][act_id].name;
}

function scr_action_cd_frac(p, act_id)
{
    if (!variable_global_exists("actions_inited") || !global.actions_inited) return 0;
    var def = global.action_defs[p.char_id][act_id];
    if (def.cd_s <= 0) return 1;
    return clamp(1 - (p.act_cd[act_id] / def.cd_s), 0, 1);
}
