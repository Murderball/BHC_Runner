function scr_menu_game_draw(_inst, _x, _y, _w)
{
    with (_inst)
    {
        menu_game_anchor_x = _x;
        menu_game_anchor_y = _y;
        menu_game_anchor_w = _w;
        menu_game_anchor_h = 0;

        scr_ui_master_volume_panel_draw(menu_game_anchor_x, menu_game_anchor_y, menu_game_anchor_w, menu_game_anchor_h, true);

        draw_set_color((menu_game_sel == 1) ? c_yellow : c_white);
        draw_text(menu_game_anchor_x + menu_game_anchor_w + options_panel_gap + options_panel_pad, menu_game_anchor_y + options_panel_align_y + options_panel_h + 18, "Back");
        draw_set_color(c_white);
    }
}
