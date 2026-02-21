/// obj_input_recorder_machine : Draw GUI

if (!recording_enabled) exit;

// Use different variable names (NOT x or y)
var gui_y = display_get_gui_height() * 0.5;
var gui_x = 40;

draw_set_alpha(1);
draw_set_color(c_red);
draw_circle(gui_x, gui_y, 10, false);

draw_set_color(c_white);
draw_text(gui_x + 20, gui_y - 8, "Record");

// Reset state
draw_set_alpha(1);
draw_set_color(c_white);