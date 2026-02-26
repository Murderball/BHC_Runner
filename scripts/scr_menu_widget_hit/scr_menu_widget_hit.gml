function scr_menu_widget_hit(_id, _mx, _my)
{
    var _w = scr_menu_widget_get(_id);
    if (!is_undefined(_w))
    {
        if (variable_struct_exists(_w, "visible") && !_w.visible) return false;
        return (_mx >= _w.x && _mx <= _w.x + _w.w && _my >= _w.y && _my <= _w.y + _w.h);
    }

    if (instance_exists(self) && variable_instance_exists(self, _id))
    {
        var _fallback = variable_instance_get(self, _id);
        if (!is_undefined(_fallback) && _fallback != noone && instance_exists(_fallback))
        {
            var _x = variable_instance_exists(_fallback, "x") ? _fallback.x : 0;
            var _y = variable_instance_exists(_fallback, "y") ? _fallback.y : 0;
            var _spr = variable_instance_exists(_fallback, "sprite_index") ? _fallback.sprite_index : -1;
            var _w_fallback = variable_instance_exists(_fallback, "w") ? _fallback.w : (sprite_exists(_spr) ? sprite_get_width(_spr) : 0);
            var _h_fallback = variable_instance_exists(_fallback, "h") ? _fallback.h : (sprite_exists(_spr) ? sprite_get_height(_spr) : 0);
            return (_mx >= _x && _mx <= _x + _w_fallback && _my >= _y && _my <= _y + _h_fallback);
        }
    }

    return false;
}
