/// obj_input_recorder_machine : Draw GUI
if (!recording_enabled) exit;

var y = display_get_gui_height() * 0.5;
var x = 40;

draw_set_alpha(1);
draw_set_color(c_red);
draw_circle(x, y, 10, false);
draw_set_color(c_white);
draw_text(x + 20, y - 8, "Record");

draw_set_alpha(1);
draw_set_color(c_white);
