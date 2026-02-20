/// obj_proj_guitar : Step

var dt = 1 / game_get_speed(gamespeed_fps);

// If we have a target, steer toward it (GUI space)
if (homing && instance_exists(target))
{
    var tp = scr_enemy_gui_pos(target);

    var dx = tp.x - gui_x;
    var dy = tp.y - gui_y;

    var ang = point_direction(0, 0, dx, dy);

    // Convert angle -> velocity
    gui_vx = lengthdir_x(speed_gui, ang);
    gui_vy = lengthdir_y(speed_gui, ang);
}

// Move in GUI-space
gui_x += gui_vx * dt;
gui_y += gui_vy * dt;

// Lifetime
life += dt;
if (life > life_max) { instance_destroy(); exit; }

// Offscreen cleanup
if (gui_x < -200 || gui_x > display_get_gui_width() + 200) { instance_destroy(); exit; }

// --- GUI HIT TEST vs enemies ---
var hit_eid = noone;
var best_d2 = 999999;
hit_x = 448;
if (variable_global_exists("HIT_X_GUI") && is_real(global.HIT_X_GUI)) hit_x = global.HIT_X_GUI;

with (obj_enemy)
{
    if (dead) continue;
    if (!variable_instance_exists(id, "t_anchor")) continue;

    var p = scr_enemy_gui_pos(id);

    // Ignore enemies that already passed the hit line.
    if (p.x < other.hit_x) continue;

    var enemy_r = 28;
    if (variable_instance_exists(id, "hit_radius")) enemy_r = id.hit_radius;

    var dx = p.x - other.gui_x;
    var dy = p.y - other.gui_y;

    var rr = (other.hit_radius + enemy_r);
    if (dx*dx + dy*dy <= rr*rr)
    {
        var d2 = dx*dx + dy*dy;
        if (d2 < best_d2) { best_d2 = d2; hit_eid = id; }
    }
}

if (instance_exists(hit_eid))
{
    if (variable_instance_exists(hit_eid, "hp"))
    {
        hit_eid.hp -= damage;
        if (hit_eid.hp < 0) hit_eid.hp = 0;

        if (hit_eid.hp <= 0)
        {
            hit_eid.dead = true;
            instance_destroy(hit_eid);
        }
    }

    if (!pierce) instance_destroy();
}
