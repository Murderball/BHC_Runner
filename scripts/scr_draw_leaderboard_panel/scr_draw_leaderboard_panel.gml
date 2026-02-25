/// scr_draw_leaderboard_panel(x, y, w, h, side, level_key, difficulty_key, allow_manage)
function scr_draw_leaderboard_panel(_x, _y, _w, _h, _side, _level_key, _difficulty_key, _allow_manage)
{
    var spr = asset_get_index("spr_leaderboard");
    var panel_w = _w;
    var panel_h = _h;
    if (spr >= 0) {
        panel_w = sprite_get_width(spr);
        panel_h = sprite_get_height(spr);
        draw_sprite(spr, 0, _x, _y);
    } else {
        draw_set_alpha(0.8);
        draw_set_color(c_black);
        draw_rectangle(_x, _y, _x + panel_w, _y + panel_h, false);
        draw_set_alpha(1);
    }

    var p = script_exists(scr_profiles_get_active) ? scr_profiles_get_active() : undefined;
    var pname = is_struct(p) ? p.name : "No Profile";
    var tops = script_exists(scr_profiles_get_top10) ? scr_profiles_get_top10(_level_key, _difficulty_key) : [];

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    draw_text(_x + 20, _y + 18, "Profile: " + pname);
    draw_text(_x + 20, _y + 40, "Level: " + string(_level_key));
    draw_text(_x + 20, _y + 62, "Difficulty: " + string_upper(string(_difficulty_key)));

    for (var i = 0; i < 10; i++) {
        var row_y = _y + 92 + i * 20;
        var txt = string(i + 1) + ". ---";
        if (i < array_length(tops) && is_struct(tops[i])) {
            var e = tops[i];
            var en = variable_struct_exists(e, "name") ? string(e.name) : "Player";
            var ea = variable_struct_exists(e, "accuracy") ? real(e.accuracy) : 0;
            txt = string(i + 1) + ". " + en + "  " + string_format(ea * 100, 0, 2) + "%";
        }
        draw_text(_x + 20, row_y, txt);
    }

    if (_allow_manage) {
        var focus_txt = global.profile_panel_focus ? "FOCUS: LEADERBOARD" : "FOCUS: MENU";
        draw_text(_x + 20, _y + panel_h - 80, focus_txt);
        draw_text(_x + 20, _y + panel_h - 60, "TAB focus | L/R profile | U/D diff");
        draw_text(_x + 20, _y + panel_h - 40, "N new | R or Enter rename");
    }
}
