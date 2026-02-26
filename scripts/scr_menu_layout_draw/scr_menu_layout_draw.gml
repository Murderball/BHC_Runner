function scr_menu_layout_draw(_inst)
{
    if (!variable_global_exists("menu_layout_editor_on") || !global.menu_layout_editor_on) return;
    if (!variable_global_exists("menu_ui") || !is_array(global.menu_ui)) return;

    if (!variable_instance_exists(_inst.id, "cam") || _inst.cam == noone) return;

    var _cx = camera_get_view_x(_inst.cam);
    var _cy = camera_get_view_y(_inst.cam);

    draw_set_alpha(1);
    draw_set_color(c_lime);

    for (var _i = 0; _i < array_length(global.menu_ui); _i++)
    {
        var _w = global.menu_ui[_i];
        if (!_w.visible) continue;

        var _x1 = _w.x - _cx;
        var _y1 = _w.y - _cy;
        var _x2 = _x1 + _w.w;
        var _y2 = _y1 + _w.h;

        draw_rectangle(_x1, _y1, _x2, _y2, true);
    }

    if (is_string(global.menu_layout_selected) && global.menu_layout_selected != "")
    {
        for (var _s = 0; _s < array_length(global.menu_ui); _s++)
        {
            var _sel = global.menu_ui[_s];
            if (_sel.id != global.menu_layout_selected) continue;

            var _sx1 = _sel.x - _cx;
            var _sy1 = _sel.y - _cy;
            var _sx2 = _sx1 + _sel.w;
            var _sy2 = _sy1 + _sel.h;

            draw_set_color(c_yellow);
            draw_rectangle(_sx1 - 2, _sy1 - 2, _sx2 + 2, _sy2 + 2, true);
            draw_set_color(c_white);
            draw_text(_sx1, _sy1 - 20, _sel.id + " (" + string(round(_sel.x)) + ", " + string(round(_sel.y)) + ")");
            break;
        }
    }

    draw_set_color(c_white);
    draw_text(16, 16, "MENU LAYOUT EDITOR (F10)  Drag | Shift=Snap | Ctrl+S Save | Ctrl+L Load");
}
