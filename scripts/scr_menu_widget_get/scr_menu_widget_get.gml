function scr_menu_widget_get(_id)
{
    if (variable_global_exists("menu_ui") && is_array(global.menu_ui))
    {
        for (var _i = 0; _i < array_length(global.menu_ui); _i++)
        {
            var _w = global.menu_ui[_i];
            if (is_struct(_w) && variable_struct_exists(_w, "id") && _w.id == _id) return _w;
        }
    }

    return undefined;
}
