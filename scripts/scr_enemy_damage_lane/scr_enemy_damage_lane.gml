/// scr_enemy_damage_lane(dmg, lane)
/// Damages the closest visible enemy in the given lane.

function scr_enemy_damage_lane(_dmg, _lane)
{
    if (_dmg <= 0) return;
    if (!instance_exists(obj_enemy)) return;

    _lane = clamp(_lane, 0, 3);

    var now_t = scr_chart_time();
    var gw    = display_get_gui_width();

    var best      = noone;
    var best_dist = 999999999;

    var n = instance_number(obj_enemy);
    for (var i = 0; i < n; i++)
    {
        var e = instance_find(obj_enemy, i);
        if (e == noone) continue;
        if (e.dead) continue;
        if (e.lane != _lane) continue;

        var xg = scr_note_screen_x(e.t_anchor, now_t);

        // visible check
        if (xg < -e.margin_px) continue;
        if (xg > gw + e.margin_px) continue;

        // Only allow hits on enemies that are still ahead of the hit line.
        if (xg < global.HIT_X_GUI) continue;

        var d = abs(xg - global.HIT_X_GUI);
        if (d < best_dist) {
            best_dist = d;
            best = e;
        }
    }

    if (best != noone)
    {
        best.hp = max(0, best.hp - _dmg);
        if (best.hp <= 0) best.dead = true;
    }
}
