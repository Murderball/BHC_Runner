function scr_ui_master_volume_panel_draw(_anchor_x, _anchor_y, _anchor_w, _anchor_h, _is_active)
{
    if (!_is_active) return;

    var _panel_w = variable_instance_exists(id, "options_panel_w") ? options_panel_w : 380;
    var _panel_h = variable_instance_exists(id, "options_panel_h") ? options_panel_h : 160;
    var _panel_pad = variable_instance_exists(id, "options_panel_pad") ? options_panel_pad : 18;
    var _panel_gap = variable_instance_exists(id, "options_panel_gap") ? options_panel_gap : 20;
    var _panel_align_y = variable_instance_exists(id, "options_panel_align_y") ? options_panel_align_y : -12;

    var _px = _anchor_x + _anchor_w + _panel_gap;
    var _py = _anchor_y + _panel_align_y;
    var _slider_min_x = _px + _panel_pad;
    var _slider_max_x = _px + _panel_w - _panel_pad - 80;
    var _slider_y = _py + 102;
    var _knob_x = lerp(_slider_min_x, _slider_max_x, clamp(global.AUDIO_MASTER, 0, 1));
    var _panel_hi = make_color_rgb(138, 214, 255);

    draw_set_alpha(0.28);
    draw_set_color(c_black);
    draw_roundrect(_px + 8, _py + 8, _px + _panel_w + 8, _py + _panel_h + 8, 10);

    draw_set_alpha(0.85);
    draw_set_color(make_color_rgb(16, 16, 20));
    draw_roundrect(_px, _py, _px + _panel_w, _py + _panel_h, 10);

    draw_set_alpha(1);
    draw_set_color(make_color_rgb(90, 90, 110));
    draw_roundrect(_px, _py, _px + _panel_w, _py + _panel_h, 10);

    draw_set_color(c_white);
    draw_text(_px + _panel_pad, _py + 16, "GAME");
    draw_text(_px + _panel_pad, _py + 52, "Master Volume");

    draw_set_halign(fa_right);
    draw_text(_px + _panel_w - _panel_pad, _py + 52, string(floor(global.AUDIO_MASTER * 100)) + "%");
    draw_set_halign(fa_left);

    draw_set_color(make_color_rgb(75, 75, 90));
    draw_line_width(_slider_min_x, _slider_y, _slider_max_x, _slider_y, 2);

    draw_set_color(_panel_hi);
    draw_line_width(_slider_min_x, _slider_y, _knob_x, _slider_y, 3);

    draw_set_color(make_color_rgb(110, 110, 130));
    draw_line_width(lerp(_slider_min_x, _slider_max_x, 0.0), _slider_y - 5, lerp(_slider_min_x, _slider_max_x, 0.0), _slider_y + 5, 1);
    draw_line_width(lerp(_slider_min_x, _slider_max_x, 0.5), _slider_y - 5, lerp(_slider_min_x, _slider_max_x, 0.5), _slider_y + 5, 1);
    draw_line_width(lerp(_slider_min_x, _slider_max_x, 1.0), _slider_y - 5, lerp(_slider_min_x, _slider_max_x, 1.0), _slider_y + 5, 1);

    draw_set_color(c_white);
    draw_circle(_knob_x, _slider_y, 8, false);
    draw_set_color(_panel_hi);
    draw_circle(_knob_x, _slider_y, 5, true);
    draw_set_color(c_white);
}
