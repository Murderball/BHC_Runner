function scr_menu_layout_init(_inst)
{
    function _widget_make(_id, _x, _y, _w, _h, _z, _visible, _draggable, _sprite, _draw_fn)
    {
        return {
            id: _id,
            x: _x,
            y: _y,
            w: _w,
            h: _h,
            z: _z,
            visible: _visible,
            draggable: _draggable,
            sprite: _sprite,
            draw_fn: _draw_fn
        };
    }

    function _safe_inst_ref(_target_inst, _varname)
    {
        if (!instance_exists(_target_inst)) return noone;
        if (!variable_instance_exists(_target_inst, _varname))
        {
            if (debug_mode) show_debug_message("[MENU LAYOUT] Missing ref: " + _varname + " using fallback defaults");
            return noone;
        }

        var _value = variable_instance_get(_target_inst, _varname);
        if (is_undefined(_value) || _value == noone || !instance_exists(_value))
        {
            if (debug_mode) show_debug_message("[MENU LAYOUT] Missing ref: " + _varname + " using fallback defaults");
            return noone;
        }

        return _value;
    }

    function _widget_from_btn(_id, _btn_inst, _default_x, _default_y, _z, _visible, _draggable, _default_sprite, _default_w, _default_h)
    {
        var _spr = _default_sprite;
        var _x = _default_x;
        var _y = _default_y;
        var _w = _default_w;
        var _h = _default_h;

        if (_btn_inst != noone && instance_exists(_btn_inst))
        {
            _x = _btn_inst.x;
            _y = _btn_inst.y;

            if (variable_instance_exists(_btn_inst, "sprite_index")) _spr = _btn_inst.sprite_index;
            if (variable_instance_exists(_btn_inst, "w")) _w = variable_instance_get(_btn_inst, "w");
            if (variable_instance_exists(_btn_inst, "h")) _h = variable_instance_get(_btn_inst, "h");
        }

        if (is_undefined(_spr)) _spr = -1;
        if (_spr >= 0)
        {
            _w = sprite_get_width(_spr);
            _h = sprite_get_height(_spr);
        }

        return _widget_make(
            _id,
            _x,
            _y,
            _w,
            _h,
            _z,
            _visible,
            _draggable,
            _spr,
            -1
        );
    }

    function _register_btn_widget(_widgets, _id, _varname, _default_x, _default_y, _z)
    {
        var _ref = _safe_inst_ref(_inst, _varname);
        array_push(_widgets, _widget_from_btn(_id, _ref, _default_x, _default_y, _z, true, true, -1, 256, 64));
    }

    function _apply_widget_pos(_target_inst, _varname, _x, _y)
    {
        if (!instance_exists(_target_inst)) return;
        if (!variable_instance_exists(_target_inst, _varname)) return;

        var _value = variable_instance_get(_target_inst, _varname);
        if (is_undefined(_value) || _value == noone || !instance_exists(_value)) return;

        _value.x = _x;
        _value.y = _y;
    }

    var _widgets = [];

    _register_btn_widget(_widgets, "btn_start", "btn_start", 960, 260, 10);
    _register_btn_widget(_widgets, "btn_story", "btn_story", 960, 332, 20);
    _register_btn_widget(_widgets, "btn_arcade", "btn_arcade", 960, 404, 20);
    _register_btn_widget(_widgets, "btn_options", "btn_options", 960, 476, 10);
    _register_btn_widget(_widgets, "btn_newgame", "btn_newgame", 960, 360, 30);
    _register_btn_widget(_widgets, "btn_loadgame", "btn_loadgame", 960, 432, 30);
    _register_btn_widget(_widgets, "btn_page_right", "btn_page_right", 1220, 650, 10);

    var ref_btn_game = _safe_inst_ref(_inst, "btn_game");
    array_push(_widgets, _widget_from_btn("btn_game", ref_btn_game, 960, 548, 15, true, true, -1, 256, 64));

    _register_btn_widget(_widgets, "btn_exit", "btn_exit", 960, 620, 15);
    _register_btn_widget(_widgets, "btn_easyL", "btn_easyL", 700, 300, 35);
    _register_btn_widget(_widgets, "btn_normalL", "btn_normalL", 960, 300, 35);
    _register_btn_widget(_widgets, "btn_hardL", "btn_hardL", 1220, 300, 35);
    _register_btn_widget(_widgets, "btn_back", "btn_back", 120, 650, 100);
    _register_btn_widget(_widgets, "btn_upgrade", "btn_upgrade", 1560, 650, 90);
    _register_btn_widget(_widgets, "btn_play", "btn_play", 1760, 650, 90);

    var _has_level_btn = variable_instance_exists(_inst, "level_btn");
    if (_has_level_btn)
    {
        var _level_btn_arr = variable_instance_get(_inst, "level_btn");
        if (is_array(_level_btn_arr))
        {
            for (var _i = 0; _i < array_length(_level_btn_arr); _i++)
            {
                var _level_ref = _level_btn_arr[_i];
                var _level_valid = (!is_undefined(_level_ref) && _level_ref != noone && instance_exists(_level_ref));
                if (!_level_valid && debug_mode) show_debug_message("[MENU LAYOUT] Missing ref: level_btn[" + string(_i) + "] using fallback defaults");
                array_push(_widgets, _widget_from_btn("level_" + string(_i), _level_valid ? _level_ref : noone, 640 + ((_i mod 6) * 220), 200 + ((_i div 6) * 100), 70, true, true, -1, 256, 64));
            }
        }
    }

    var _has_char_btn = variable_instance_exists(_inst, "char_btn");
    if (_has_char_btn)
    {
        var _char_btn_arr = variable_instance_get(_inst, "char_btn");
        if (is_array(_char_btn_arr))
        {
            for (var _j = 0; _j < array_length(_char_btn_arr); _j++)
            {
                var _char_ref = _char_btn_arr[_j];
                var _char_valid = (!is_undefined(_char_ref) && _char_ref != noone && instance_exists(_char_ref));
                if (!_char_valid && debug_mode) show_debug_message("[MENU LAYOUT] Missing ref: char_btn[" + string(_j) + "] using fallback defaults");
                array_push(_widgets, _widget_from_btn("char_" + string(_j), _char_valid ? _char_ref : noone, 640 + ((_j mod 6) * 220), 500 + ((_j div 6) * 100), 80, true, true, -1, 256, 64));
            }
        }
    }

    global.menu_ui = _widgets;

    global.menu_layout_editor_on = false;
    global.menu_layout_selected = "";
    global.menu_layout_dragging = false;
    global.menu_layout_drag_dx = 0;
    global.menu_layout_drag_dy = 0;

    var _layout_rel = "layouts/menu_layout.json";
    var _layout_path = working_directory + _layout_rel;
    if (file_exists(_layout_path))
    {
        var _f = file_text_open_read(_layout_path);
        var _json = "";
        while (!file_text_eof(_f)) _json += file_text_read_string(_f);
        file_text_close(_f);

        var _data = json_parse(_json);
        if (is_struct(_data))
        {
            for (var _k = 0; _k < array_length(global.menu_ui); _k++)
            {
                var _wgt = global.menu_ui[_k];
                if (variable_struct_exists(_data, _wgt.id))
                {
                    var _p = variable_struct_get(_data, _wgt.id);
                    if (is_struct(_p))
                    {
                        if (variable_struct_exists(_p, "x")) _wgt.x = _p.x;
                        if (variable_struct_exists(_p, "y")) _wgt.y = _p.y;
                    }
                }
            }
        }
    }

    for (var _wi = 0; _wi < array_length(global.menu_ui); _wi++)
    {
        var _w = global.menu_ui[_wi];
        switch (_w.id)
        {
            case "btn_start": _apply_widget_pos(_inst, "btn_start", _w.x, _w.y); break;
            case "btn_story": _apply_widget_pos(_inst, "btn_story", _w.x, _w.y); break;
            case "btn_arcade": _apply_widget_pos(_inst, "btn_arcade", _w.x, _w.y); break;
            case "btn_options": _apply_widget_pos(_inst, "btn_options", _w.x, _w.y); break;
            case "btn_newgame": _apply_widget_pos(_inst, "btn_newgame", _w.x, _w.y); break;
            case "btn_loadgame": _apply_widget_pos(_inst, "btn_loadgame", _w.x, _w.y); break;
            case "btn_page_right": _apply_widget_pos(_inst, "btn_page_right", _w.x, _w.y); break;
            case "btn_game": _apply_widget_pos(_inst, "btn_game", _w.x, _w.y); break;
            case "btn_exit": _apply_widget_pos(_inst, "btn_exit", _w.x, _w.y); break;
            case "btn_easyL": _apply_widget_pos(_inst, "btn_easyL", _w.x, _w.y); break;
            case "btn_normalL": _apply_widget_pos(_inst, "btn_normalL", _w.x, _w.y); break;
            case "btn_hardL": _apply_widget_pos(_inst, "btn_hardL", _w.x, _w.y); break;
            case "btn_back": _apply_widget_pos(_inst, "btn_back", _w.x, _w.y); break;
            case "btn_upgrade": _apply_widget_pos(_inst, "btn_upgrade", _w.x, _w.y); break;
            case "btn_play": _apply_widget_pos(_inst, "btn_play", _w.x, _w.y); break;
            default:
                if (string_pos("level_", _w.id) == 1 && variable_instance_exists(_inst, "level_btn"))
                {
                    var _level_btn = variable_instance_get(_inst, "level_btn");
                    var _li = real(string_delete(_w.id, 1, 6));
                    if (is_array(_level_btn) && _li >= 0 && _li < array_length(_level_btn))
                    {
                        var _lb = _level_btn[_li];
                        if (!is_undefined(_lb) && _lb != noone && instance_exists(_lb))
                        {
                            _lb.x = _w.x;
                            _lb.y = _w.y;
                        }
                    }
                }
                else if (string_pos("char_", _w.id) == 1 && variable_instance_exists(_inst, "char_btn"))
                {
                    var _char_btn = variable_instance_get(_inst, "char_btn");
                    var _ci = real(string_delete(_w.id, 1, 5));
                    if (is_array(_char_btn) && _ci >= 0 && _ci < array_length(_char_btn))
                    {
                        var _cb = _char_btn[_ci];
                        if (!is_undefined(_cb) && _cb != noone && instance_exists(_cb))
                        {
                            _cb.x = _w.x;
                            _cb.y = _w.y;
                        }
                    }
                }
            break;
        }
    }
}
