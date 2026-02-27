function scr_menu_layout_editor_step(inst)
{
    if (room != rm_menu) return false;

    function _widget_is_on_page(_w, _page)
    {
        if (!is_struct(_w)) return false;

        if (variable_struct_exists(_w, "menu_page")) return (_w.menu_page == _page);

        switch (_w.id)
        {
            case "btn_start":
            case "btn_story":
            case "btn_arcade":
            case "btn_options":
            case "btn_exit":
                return (_page == 0);

            case "btn_back":
            case "char_vocalist":
            case "char_guitarist":
            case "char_bassist":
            case "char_drummer":
            case "char_0":
            case "char_1":
            case "char_2":
            case "char_3":
                return (_page == 1);
        }

        return false;
    }

    function _active_widget_indices(_page)
    {
        var _indices = [];

        for (var _i = 0; _i < array_length(global.menu_ui); _i++)
        {
            var _w = global.menu_ui[_i];
            if (_widget_is_on_page(_w, _page)) array_push(_indices, _i);
        }

        return _indices;
    }

    function _char_index_from_id(_id)
    {
        if (_id == "char_vocalist") return 0;
        if (_id == "char_guitarist") return 1;
        if (_id == "char_bassist") return 2;
        if (_id == "char_drummer") return 3;
        if (string_pos("char_", _id) == 1) return real(string_delete(_id, 1, 5));
        return -1;
    }

    if (!variable_global_exists("menu_layout_editor_on")) global.menu_layout_editor_on = false;
    if (!variable_global_exists("menu_layout_selected")) global.menu_layout_selected = "";
    if (!variable_global_exists("menu_layout_dragging")) global.menu_layout_dragging = false;
    if (!variable_global_exists("menu_layout_drag_dx")) global.menu_layout_drag_dx = 0;
    if (!variable_global_exists("menu_layout_drag_dy")) global.menu_layout_drag_dy = 0;
    if (!variable_global_exists("menu_editor_page")) global.menu_editor_page = 0;
    if (!variable_global_exists("menu_ui") || !is_array(global.menu_ui)) return false;

    if (keyboard_check_pressed(vk_f10))
    {
        global.menu_layout_editor_on = !global.menu_layout_editor_on;
        if (!global.menu_layout_editor_on)
        {
            global.menu_layout_dragging = false;
            global.menu_layout_selected = "";
        }
        else
        {
            global.menu_editor_page = clamp(global.menu_editor_page, 0, 1);

            if (instance_exists(inst))
            {
                var _target_x = room_width * 0.5;

                if (global.menu_editor_page == 0)
                {
                    if (variable_instance_exists(inst, "page_left_x")) _target_x = inst.page_left_x;
                }
                else
                {
                    if (variable_instance_exists(inst, "page_right_x")) _target_x = inst.page_right_x;
                }

                inst.cam_target_x = _target_x;

                if (variable_instance_exists(inst, "menu_cam_target_x")) inst.menu_cam_target_x = _target_x;
                if (variable_instance_exists(inst, "menu_page_target_x")) inst.menu_page_target_x = _target_x;
                if (variable_instance_exists(inst, "menu_cam_x")) inst.menu_cam_x = _target_x;
                if (variable_instance_exists(inst, "cam_x")) inst.cam_x = _target_x;
                if (variable_instance_exists(inst, "menu_page_x")) inst.menu_page_x = _target_x;

                if (variable_instance_exists(inst, "cam") && inst.cam != noone)
                {
                    var _target_y = camera_get_view_y(inst.cam);
                    if (variable_instance_exists(inst, "menu_cam_y")) _target_y = inst.menu_cam_y;
                    camera_set_view_pos(inst.cam, _target_x, _target_y);
                }
            }

            global.menu_layout_selected = "";
            global.menu_layout_dragging = false;
        }
    }

    if (!global.menu_layout_editor_on) return false;

    if (keyboard_check_pressed(vk_tab))
    {
        global.menu_editor_page = 1 - global.menu_editor_page;

        if (instance_exists(inst))
        {
            var _target_x = room_width * 0.5;

            if (global.menu_editor_page == 0)
            {
                if (variable_instance_exists(inst, "page_left_x")) _target_x = inst.page_left_x;
            }
            else
            {
                if (variable_instance_exists(inst, "page_right_x")) _target_x = inst.page_right_x;
            }

            inst.cam_target_x = _target_x;

            if (variable_instance_exists(inst, "menu_cam_target_x")) inst.menu_cam_target_x = _target_x;
            if (variable_instance_exists(inst, "menu_page_target_x")) inst.menu_page_target_x = _target_x;
            if (variable_instance_exists(inst, "menu_cam_x")) inst.menu_cam_x = _target_x;
            if (variable_instance_exists(inst, "cam_x")) inst.cam_x = _target_x;
            if (variable_instance_exists(inst, "menu_page_x")) inst.menu_page_x = _target_x;

            if (variable_instance_exists(inst, "cam") && inst.cam != noone)
            {
                var _target_y = camera_get_view_y(inst.cam);
                if (variable_instance_exists(inst, "menu_cam_y")) _target_y = inst.menu_cam_y;
                camera_set_view_pos(inst.cam, _target_x, _target_y);
            }
        }

        global.menu_layout_selected = "";
        global.menu_layout_dragging = false;
    }

    var _active_indices = _active_widget_indices(global.menu_editor_page);

    var _ctrl = keyboard_check(vk_control);
    var _layout_rel = "layouts/menu_layout.json";
    var _layout_dir = working_directory + "layouts";
    var _layout_path = working_directory + _layout_rel;

    if (_ctrl && keyboard_check_pressed(ord("S")))
    {
        if (!directory_exists(_layout_dir)) directory_create(_layout_dir);

        var _out = {};
        for (var _i = 0; _i < array_length(global.menu_ui); _i++)
        {
            var _w = global.menu_ui[_i];
            variable_struct_set(_out, _w.id, { x: _w.x, y: _w.y });
        }

        var _json = json_stringify(_out);
        var _fw = file_text_open_write(_layout_path);
        file_text_write_string(_fw, _json);
        file_text_close(_fw);
    }

    if (_ctrl && keyboard_check_pressed(ord("L")))
    {
        if (file_exists(_layout_path))
        {
            var _fr = file_text_open_read(_layout_path);
            var _in_json = "";
            while (!file_text_eof(_fr)) _in_json += file_text_read_string(_fr);
            file_text_close(_fr);

            var _data = json_parse(_in_json);
            if (is_struct(_data))
            {
                for (var _j = 0; _j < array_length(global.menu_ui); _j++)
                {
                    var _lw = global.menu_ui[_j];
                    if (variable_struct_exists(_data, _lw.id))
                    {
                        var _p = variable_struct_get(_data, _lw.id);
                        if (is_struct(_p))
                        {
                            if (variable_struct_exists(_p, "x")) _lw.x = _p.x;
                            if (variable_struct_exists(_p, "y")) _lw.y = _p.y;
                        }
                    }
                }
            }
        }
    }

    var _cx = camera_get_view_x(inst.cam);
    var _cy = camera_get_view_y(inst.cam);
    var _mx = device_mouse_x_to_gui(0) + _cx;
    var _my = device_mouse_y_to_gui(0) + _cy;

    if (mouse_check_button_pressed(mb_left))
    {
        var _pick = -1;
        var _best_z = -1000000;

        for (var _k = 0; _k < array_length(_active_indices); _k++)
        {
            var _idx = _active_indices[_k];
            var _hit = global.menu_ui[_idx];
            if (!_hit.visible || !_hit.draggable) continue;

            var _inside = (_mx >= _hit.x && _mx <= _hit.x + _hit.w && _my >= _hit.y && _my <= _hit.y + _hit.h);
            if (!_inside) continue;

            if (_hit.z >= _best_z)
            {
                _best_z = _hit.z;
                _pick = _idx;
            }
        }

        if (_pick >= 0)
        {
            var _sel = global.menu_ui[_pick];
            global.menu_layout_selected = _sel.id;
            global.menu_layout_dragging = true;
            global.menu_layout_drag_dx = _mx - _sel.x;
            global.menu_layout_drag_dy = _my - _sel.y;
        }
        else
        {
            global.menu_layout_selected = "";
            global.menu_layout_dragging = false;
        }
    }

    if (global.menu_layout_dragging)
    {
        if (mouse_check_button(mb_left) && is_string(global.menu_layout_selected) && global.menu_layout_selected != "")
        {
            for (var _m = 0; _m < array_length(_active_indices); _m++)
            {
                var _drag = global.menu_ui[_active_indices[_m]];
                if (_drag.id != global.menu_layout_selected) continue;

                var _nx = _mx - global.menu_layout_drag_dx;
                var _ny = _my - global.menu_layout_drag_dy;

                if (keyboard_check(vk_shift))
                {
                    _nx = round(_nx / 16) * 16;
                    _ny = round(_ny / 16) * 16;
                }

                _drag.x = _nx;
                _drag.y = _ny;
                break;
            }
        }
        else
        {
            global.menu_layout_dragging = false;
        }
    }

    var _id = inst;
    if (!variable_instance_exists(_id, "btn_game"))
    {
        with (_id)
        {
            var _spr = asset_get_index("menu_game");
            btn_game = { spr: _spr, x: 0, y: 0, w: BTN_W, h: BTN_H };
        }
    }

    with (inst)
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
                        var _ci = _char_index_from_id(_w.id);
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

    return true;
}
