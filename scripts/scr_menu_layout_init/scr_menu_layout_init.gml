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

    function _widget_from_btn(_id, _btn, _z, _visible)
    {
        var _spr = -1;
        if (variable_struct_exists(_btn, "spr")) _spr = _btn.spr;

        var _w = variable_struct_exists(_btn, "w") ? _btn.w : 64;
        var _h = variable_struct_exists(_btn, "h") ? _btn.h : 64;
        if (_spr >= 0)
        {
            _w = sprite_get_width(_spr);
            _h = sprite_get_height(_spr);
        }

        return _widget_make(
            _id,
            _btn.x,
            _btn.y,
            _w,
            _h,
            _z,
            _visible,
            true,
            _spr,
            -1
        );
    }

    var _widgets = [];

    array_push(_widgets, _widget_from_btn("btn_start", _inst.btn_start, 10, true));
    array_push(_widgets, _widget_from_btn("btn_story", _inst.btn_story, 20, true));
    array_push(_widgets, _widget_from_btn("btn_arcade", _inst.btn_arcade, 20, true));
    array_push(_widgets, _widget_from_btn("btn_options", _inst.btn_options, 10, true));
    array_push(_widgets, _widget_from_btn("btn_newgame", _inst.btn_newgame, 30, true));
    array_push(_widgets, _widget_from_btn("btn_loadgame", _inst.btn_loadgame, 30, true));
    array_push(_widgets, _widget_from_btn("btn_page_right", _inst.btn_page_right, 10, true));
    array_push(_widgets, _widget_from_btn("btn_game", _inst.btn_game, 15, true));
    array_push(_widgets, _widget_from_btn("btn_exit", _inst.btn_exit, 15, true));
    array_push(_widgets, _widget_from_btn("btn_easyL", _inst.btn_easyL, 35, true));
    array_push(_widgets, _widget_from_btn("btn_normalL", _inst.btn_normalL, 35, true));
    array_push(_widgets, _widget_from_btn("btn_hardL", _inst.btn_hardL, 35, true));
    array_push(_widgets, _widget_from_btn("btn_back", _inst.btn_back, 100, true));
    array_push(_widgets, _widget_from_btn("btn_upgrade", _inst.btn_upgrade, 90, true));
    array_push(_widgets, _widget_from_btn("btn_play", _inst.btn_play, 90, true));

    for (var _i = 0; _i < array_length(_inst.level_btn); _i++)
    {
        array_push(_widgets, _widget_from_btn("level_" + string(_i), _inst.level_btn[_i], 70, true));
    }

    for (var _j = 0; _j < array_length(_inst.char_btn); _j++)
    {
        array_push(_widgets, _widget_from_btn("char_" + string(_j), _inst.char_btn[_j], 80, true));
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

    with (_inst)
    {
        for (var _wi = 0; _wi < array_length(global.menu_ui); _wi++)
        {
            var _w = global.menu_ui[_wi];
            switch (_w.id)
            {
                case "btn_start": btn_start.x = _w.x; btn_start.y = _w.y; break;
                case "btn_story": btn_story.x = _w.x; btn_story.y = _w.y; break;
                case "btn_arcade": btn_arcade.x = _w.x; btn_arcade.y = _w.y; break;
                case "btn_options": btn_options.x = _w.x; btn_options.y = _w.y; break;
                case "btn_newgame": btn_newgame.x = _w.x; btn_newgame.y = _w.y; break;
                case "btn_loadgame": btn_loadgame.x = _w.x; btn_loadgame.y = _w.y; break;
                case "btn_page_right": btn_page_right.x = _w.x; btn_page_right.y = _w.y; break;
                case "btn_game": btn_game.x = _w.x; btn_game.y = _w.y; break;
                case "btn_exit": btn_exit.x = _w.x; btn_exit.y = _w.y; break;
                case "btn_easyL": btn_easyL.x = _w.x; btn_easyL.y = _w.y; break;
                case "btn_normalL": btn_normalL.x = _w.x; btn_normalL.y = _w.y; break;
                case "btn_hardL": btn_hardL.x = _w.x; btn_hardL.y = _w.y; break;
                case "btn_back": btn_back.x = _w.x; btn_back.y = _w.y; break;
                case "btn_upgrade": btn_upgrade.x = _w.x; btn_upgrade.y = _w.y; break;
                case "btn_play": btn_play.x = _w.x; btn_play.y = _w.y; break;
                default:
                    if (string_pos("level_", _w.id) == 1)
                    {
                        var _li = real(string_delete(_w.id, 1, 6));
                        if (_li >= 0 && _li < array_length(level_btn))
                        {
                            var _lb = level_btn[_li];
                            _lb.x = _w.x;
                            _lb.y = _w.y;
                            level_btn[_li] = _lb;
                        }
                    }
                    else if (string_pos("char_", _w.id) == 1)
                    {
                        var _ci = real(string_delete(_w.id, 1, 5));
                        if (_ci >= 0 && _ci < array_length(char_btn))
                        {
                            var _cb = char_btn[_ci];
                            _cb.x = _w.x;
                            _cb.y = _w.y;
                            char_btn[_ci] = _cb;
                        }
                    }
                break;
            }
        }
    }
}
