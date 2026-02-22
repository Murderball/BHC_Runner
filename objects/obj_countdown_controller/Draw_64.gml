/// obj_countdown_controller : Draw GUI
if (!global.COUNTDOWN_ACTIVE) exit;

var spb = scr_seconds_per_beat();
var remaining = global.COUNTDOWN_TIMER_S;
var beat_index = floor(remaining / spb);
var phase = frac(remaining / spb);

var label = "GO!";
switch (beat_index)
{
    case 3: label = "3"; break;
    case 2: label = "2"; break;
    case 1: label = "1"; break;
    default: label = "GO!"; break;
}

var gw = display_get_gui_width();
var gh = display_get_gui_height();
var cx = gw * 0.5;
var cy = gh * 0.5;

var pulse = 1.0 + (1.0 - phase) * 0.08;
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(0.75);
draw_set_color(c_black);
draw_text_transformed(cx + 3, cy + 3, label, pulse, pulse, 0);

draw_set_alpha(1);
draw_set_color(c_white);
draw_text_transformed(cx, cy, label, pulse, pulse, 0);
