function scr_menu_game_update(_inst, _ok, _back, _left, _right, _up, _down)
{
    with (_inst)
    {
        if (_back)
        {
            if (menu_game_adjust) menu_game_adjust = false;
            else menu_game_open = false;
            return;
        }

        if (_up || _down) menu_game_sel = (menu_game_sel + 1) mod 2;

        if (menu_game_sel == 0)
        {
            if (_right && !menu_game_adjust) menu_game_adjust = true;

            ui_mouse_x = device_mouse_x_to_gui(0);
            ui_mouse_y = device_mouse_y_to_gui(0);
            ui_input_left = _left;
            ui_input_right = _right;
            scr_ui_master_volume_panel_update(menu_game_anchor_x, menu_game_anchor_y, menu_game_anchor_w, menu_game_anchor_h, true);

            if (_ok)
            {
                if (menu_game_adjust) menu_game_adjust = false;
                else menu_game_sel = 1;
            }
        }
        else if (_ok || _left || _back)
        {
            menu_game_open = false;
        }
    }
}
