/// scr_find_nearest_enemy_gui(from_x, from_y, max_range)
/// Returns the nearest living obj_enemy by GUI-space distance.
/// Safe: does not reference caller instance vars via `other`.
function scr_find_nearest_enemy_gui(from_x, from_y, max_range)
{
    // Copy args into locals so `with()` can use them safely
    var fx = from_x;
    var fy = from_y;

    if (!is_real(fx)) fx = 448;
    if (!is_real(fy)) fy = display_get_gui_height() * 0.5;

    var best    = noone;
    var best_d2 = 999999;

    var w = display_get_gui_width();
    var h = display_get_gui_height();
    var hit_x = 448;
    if (variable_global_exists("HIT_X_GUI") && is_real(global.HIT_X_GUI)) hit_x = global.HIT_X_GUI;

    var mr = max_range;
    if (!is_real(mr) || mr <= 0) mr = 2500;
    var r2 = mr * mr;

    with (obj_enemy)
    {
        if (variable_instance_exists(id, "dead") && dead) continue;

        // Must be a valid timeline enemy
        if (!variable_instance_exists(id, "t_anchor")) continue;
        if (!is_real(t_anchor)) continue;

        // Get GUI position
        var p = scr_enemy_gui_pos(id);

        // Optional: ignore way-offscreen enemies (keeps targeting sane)
        if (p.x < -400 || p.x > w + 400) continue;
        if (p.y < -400 || p.y > h + 400) continue;

        // Ignore enemies that already passed the hit line.
        if (p.x < hit_x) continue;

        var dx = p.x - fx;
        var dy = p.y - fy;
        var d2 = dx*dx + dy*dy;

        if (d2 <= r2 && d2 < best_d2)
        {
            best_d2 = d2;
            best = id;
        }
    }

    return best;
}
