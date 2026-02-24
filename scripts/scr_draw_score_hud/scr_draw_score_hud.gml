/// scr_draw_score_hud(_x, _y)
/// Draws a compact score HUD in GUI coordinates.
function scr_draw_score_hud(_x, _y)
{
    var _old_alpha = draw_get_alpha();
    var _old_color = draw_get_color();
    var _old_font  = draw_get_font();
    var _old_halign = draw_get_halign();
    var _old_valign = draw_get_valign();

    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();

    var _score = 0;
    var _combo = 0;
    var _mult = 1.0;
    var _acc = 0.0;
    var _p = 0;
    var _g = 0;
    var _b = 0;
    var _m = 0;

    var _has_score = variable_global_exists("score_state") && is_struct(global.score_state);

    if (_has_score) {
        var _st = global.score_state;

        if (variable_struct_exists(_st, "score_total")) _score = _st.score_total;
        if (variable_struct_exists(_st, "combo")) _combo = _st.combo;

        if (variable_struct_exists(_st, "multiplier_current")) {
            _mult = _st.multiplier_current;
        } else if (variable_struct_exists(_st, "multiplier")) {
            _mult = _st.multiplier;
        }

        if (variable_struct_exists(_st, "accuracy_percent")) _acc = _st.accuracy_percent;

        if (variable_struct_exists(_st, "count_perfect")) _p = _st.count_perfect;
        if (variable_struct_exists(_st, "count_good")) _g = _st.count_good;
        if (variable_struct_exists(_st, "count_bad")) _b = _st.count_bad;
        if (variable_struct_exists(_st, "count_miss")) _m = _st.count_miss;
    }

    var _pad = 12;
    var _line_h = 20;
    var _panel_w = 240;
    var _panel_h = _pad * 2 + (_line_h * 5);

    _x = clamp(_x, 0, max(0, _gui_w - _panel_w));
    _y = clamp(_y, 0, max(0, _gui_h - _panel_h));

    draw_set_font(-1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_alpha(0.68);
    draw_set_color(c_black);
    draw_rectangle(_x, _y, _x + _panel_w, _y + _panel_h, false);

    draw_set_alpha(0.25);
    draw_set_color(c_white);
    draw_rectangle(_x, _y, _x + _panel_w, _y + 2, false);

    var _tx = _x + _pad;
    var _ty = _y + _pad;

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(_tx, _ty + (_line_h * 0), "SCORE: " + string(_score));
    draw_text(_tx, _ty + (_line_h * 1), "COMBO: " + string(_combo));
    draw_text(_tx, _ty + (_line_h * 2), "MULT: x" + string_format(_mult, 1, 2));
    draw_text(_tx, _ty + (_line_h * 3), "ACC: " + string_format(_acc, 1, 1) + "%");

    draw_set_color(make_color_rgb(180, 180, 180));
    draw_text(_tx, _ty + (_line_h * 4), "P:" + string(_p) + " G:" + string(_g) + " B:" + string(_b) + " M:" + string(_m));

    draw_set_alpha(_old_alpha);
    draw_set_color(_old_color);
    draw_set_font(_old_font);
    draw_set_halign(_old_halign);
    draw_set_valign(_old_valign);
}
