function scr_menu_game_draw(_inst, _x, _y, _w)
{
    with (_inst)
    {
        var _h = 40;
        var _gap = 22;

        var _row0_y = _y;
        var _row1_y = _y + _h + _gap;

        var _pct = floor(global.AUDIO_MASTER * 100);
        var _bar_w = max(120, _w * 0.45);
        var _bar_h = 16;
        var _bar_x = _x + _w - _bar_w;
        var _bar_y = _row0_y + 12;

        draw_set_color(c_white);
        draw_text(_x, _y - 36, "GAME");

        draw_set_color((menu_game_sel == 0) ? c_yellow : c_white);
        draw_text(_x, _row0_y, "Master Volume");
        draw_set_color(c_white);
        draw_text(_bar_x - 70, _row0_y, string(_pct) + "%");

        draw_set_alpha(0.35);
        draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
        draw_set_alpha(1);

        draw_set_color(c_lime);
        draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_w * global.AUDIO_MASTER), _bar_y + _bar_h, false);

        draw_set_color((menu_game_sel == 1) ? c_yellow : c_white);
        draw_text(_x, _row1_y, "Back");

        if (menu_game_adjust && menu_game_sel == 0)
        {
            draw_set_color(c_yellow);
            draw_text(_x + 220, _row0_y, "<  >");
        }

        draw_set_color(c_white);
    }
}
