/// scr_draw_score_hud(_x, _y)
/// Draws a compact score HUD panel in GUI space.
function scr_draw_score_hud(_x, _y)
{
    var _old_alpha = draw_get_alpha();
    var _old_colour = draw_get_colour();
    var _old_font = draw_get_font();
    var _old_halign = draw_get_halign();
    var _old_valign = draw_get_valign();

    var _score = 0;
    var _combo = 0;
    var _mult = 1.0;
    var _acc = 0.0;
    var _p = 0;
    var _g = 0;
    var _b = 0;
    var _m = 0;

    if (variable_global_exists("score_state") && is_struct(global.score_state)) {
        var _has_snapshot = false;
        if (variable_global_exists("scr_score_get_snapshot") && is_callable(scr_score_get_snapshot)) {
            var _snap = scr_score_get_snapshot();
            if (is_struct(_snap)) {
                _has_snapshot = true;
                if (variable_struct_exists(_snap, "score_total")) _score = _snap.score_total;
                if (variable_struct_exists(_snap, "combo")) _combo = _snap.combo;

                if (variable_struct_exists(_snap, "multiplier_current")) {
                    _mult = _snap.multiplier_current;
                } else if (variable_struct_exists(_snap, "multiplier")) {
                    _mult = _snap.multiplier;
                }

                if (variable_struct_exists(_snap, "accuracy_percent")) _acc = _snap.accuracy_percent;
                if (variable_struct_exists(_snap, "count_perfect")) _p = _snap.count_perfect;
                if (variable_struct_exists(_snap, "count_good")) _g = _snap.count_good;
                if (variable_struct_exists(_snap, "count_bad")) _b = _snap.count_bad;
                if (variable_struct_exists(_snap, "count_miss")) _m = _snap.count_miss;
            }
        }

        if (!_has_snapshot) {
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
    }

    var _pad = 12;
    var _line_h = 20;
    var _title_h = 18;

    var _line_score = "SCORE: " + string(_score);
    var _line_combo = "COMBO: " + string(_combo);
    var _line_mult = "MULT: x" + string_format(_mult, 1, 2);
    var _line_acc = "ACC: " + string_format(_acc, 1, 1) + "%";
    var _line_judges = "P:" + string(_p) + " G:" + string(_g) + " B:" + string(_b) + " M:" + string(_m);

    var _panel_w = 248;
    var _panel_h = _pad + _title_h + (_line_h * 5) + _pad;

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);

    draw_set_alpha(0.68);
    draw_set_colour(c_black);
    draw_roundrect(_x, _y, _x + _panel_w, _y + _panel_h, false);

    draw_set_alpha(0.30);
    draw_set_colour(c_white);
    draw_rectangle(_x + 1, _y + 1, _x + _panel_w - 1, _y + 4, false);

    draw_set_alpha(0.55);
    draw_set_colour(make_colour_rgb(160, 160, 160));
    draw_rectangle(_x, _y, _x + _panel_w, _y + _panel_h, true);

    var _text_x = _x + _pad;
    var _text_y = _y + _pad;

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_text(_text_x, _text_y, "SCORE HUD");

    _text_y += _title_h;
    draw_text(_text_x, _text_y + (_line_h * 0), _line_score);
    draw_text(_text_x, _text_y + (_line_h * 1), _line_combo);
    draw_text(_text_x, _text_y + (_line_h * 2), _line_mult);
    draw_text(_text_x, _text_y + (_line_h * 3), _line_acc);

    draw_set_colour(make_colour_rgb(190, 190, 190));
    draw_text(_text_x, _text_y + (_line_h * 4), _line_judges);

    draw_set_alpha(1);
    draw_set_colour(_old_colour);
    draw_set_font(_old_font);
    draw_set_halign(_old_halign);
    draw_set_valign(_old_valign);
    draw_set_alpha(_old_alpha);
}
