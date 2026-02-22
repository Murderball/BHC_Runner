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

        var _changed = false;

        if (menu_game_sel == 0)
        {
            if (_right && !menu_game_adjust) menu_game_adjust = true;

            if (_left || _right)
            {
                var _dir = (_right ? 1 : 0) - (_left ? 1 : 0);
                if (_dir != 0)
                {
                    global.AUDIO_MASTER = clamp(global.AUDIO_MASTER + (menu_game_step * _dir), 0.0, 1.0);
                    _changed = true;
                }
            }

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

        if (_changed)
        {
            scr_audio_settings_apply();
            scr_audio_settings_save();
        }
    }
}
