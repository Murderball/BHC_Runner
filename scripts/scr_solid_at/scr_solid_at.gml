/// scr_solid_at(x, y)
function scr_solid_at(_x, _y)
{
    if (!variable_global_exists("tm_collide")) return false;

    var tm = global.tm_collide;
    if (is_undefined(tm) || tm == -1) return false;

    // Tilemap IDs are usually > 0. If you ever see <= 0, the tilemap isn't initialized.
    if (tm <= 0) show_debug_message("[tm_collide] invalid value=" + string(tm));

    var tiledata = tilemap_get_at_pixel(tm, _x, _y);
    return (tiledata != 0);
}
