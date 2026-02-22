function scr_ui_master_volume_panel_update(_anchor_x, _anchor_y, _anchor_w, _anchor_h, _is_active)
{
    var _panel_w = variable_instance_exists(id, "options_panel_w") ? options_panel_w : 380;
    var _panel_h = variable_instance_exists(id, "options_panel_h") ? options_panel_h : 160;
    var _panel_pad = variable_instance_exists(id, "options_panel_pad") ? options_panel_pad : 18;
    var _panel_gap = variable_instance_exists(id, "options_panel_gap") ? options_panel_gap : 20;
    var _panel_align_y = variable_instance_exists(id, "options_panel_align_y") ? options_panel_align_y : -12;
    var _step = variable_instance_exists(id, "options_slider_step") ? options_slider_step : 0.05;

    var _mx = variable_instance_exists(id, "ui_mouse_x") ? ui_mouse_x : device_mouse_x_to_gui(0);
    var _my = variable_instance_exists(id, "ui_mouse_y") ? ui_mouse_y : device_mouse_y_to_gui(0);
    var _left = variable_instance_exists(id, "ui_input_left") ? ui_input_left : (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")));
    var _right = variable_instance_exists(id, "ui_input_right") ? ui_input_right : (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")));

    var _px = _anchor_x + _anchor_w + _panel_gap;
    var _py = _anchor_y + _panel_align_y;
    var _slider_min_x = _px + _panel_pad;
    var _slider_max_x = _px + _panel_w - _panel_pad - 80;
    var _slider_y = _py + 102;

    options_panel_x = _px;
    options_panel_y = _py;
    options_slider_min_x = _slider_min_x;
    options_slider_max_x = _slider_max_x;
    options_slider_y = _slider_y;

    var _knob_x_now = lerp(_slider_min_x, _slider_max_x, clamp(global.AUDIO_MASTER, 0, 1));
    var _hit_track = _is_active && (_mx >= _slider_min_x - 8) && (_mx <= _slider_max_x + 8) && (_my >= _slider_y - 12) && (_my <= _slider_y + 12);
    var _hit_knob = _is_active && point_distance(_mx, _my, _knob_x_now, _slider_y) <= 16;

    var _changed = false;

    if (_is_active)
    {
        var _dir = (_right ? 1 : 0) - (_left ? 1 : 0);
        if (_dir != 0)
        {
            global.AUDIO_MASTER = clamp(global.AUDIO_MASTER + (_step * _dir), 0.0, 1.0);
            _changed = true;
        }

        if (mouse_check_button_pressed(mb_left) && (_hit_track || _hit_knob))
        {
            options_slider_drag = true;
            if (variable_instance_exists(id, "menu_game_adjust")) menu_game_adjust = true;
        }

        if (!mouse_check_button(mb_left)) options_slider_drag = false;

        if (options_slider_drag)
        {
            var _t = clamp((_mx - _slider_min_x) / max(1, _slider_max_x - _slider_min_x), 0, 1);
            global.AUDIO_MASTER = _t;
            _changed = true;
        }
        else if (mouse_check_button_pressed(mb_left) && _hit_track)
        {
            var _tm = clamp((_mx - _slider_min_x) / max(1, _slider_max_x - _slider_min_x), 0, 1);
            global.AUDIO_MASTER = _tm;
            _changed = true;
        }
    }
    else
    {
        options_slider_drag = false;
    }

    if (_changed)
    {
        scr_audio_settings_apply();
        scr_audio_settings_save();
    }

    return {
        changed : _changed,
        hit_track : _hit_track,
        hit_knob : _hit_knob
    };
}
