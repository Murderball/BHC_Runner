/// obj_input_recorder : Draw GUI

editor_mode = (variable_global_exists("editor_on") && global.editor_on);
if (!editor_mode) exit;
if (!variable_global_exists("input_recorder") || !is_struct(global.input_recorder)) exit;

var gui_x = ui_x;
var gui_y = ui_y;

var col_bg = c_black;
var col_on = c_lime;
var col_off = c_red;

for (var i = 0; i < array_length(box_labels); i++) {
    var bx1 = gui_x + i * (ui_w + ui_gap);
    var by1 = gui_y;
    var bx2 = bx1 + ui_w;
    var by2 = by1 + ui_h;

    draw_set_alpha(0.67);
    draw_set_color(col_bg);
    draw_roundrect(bx1, by1, bx2, by2, false);

    draw_set_color(c_white);
    draw_text(bx1 + 10, by1 + 13, box_labels[i]);
}

draw_set_alpha(1);

var st_y = gui_y + ui_h + 12;
var is_rec = global.input_recorder.recording;
var onoff = global.input_recorder.enabled ? "ON" : "OFF";
var recst = is_rec ? "REC" : "STOP";

draw_set_color(c_white);
draw_text(gui_x, st_y, "Input Recorder [F9 toggle, F10 clear]");
draw_text(gui_x, st_y + 18, "Enabled: " + onoff);
draw_set_color(is_rec ? col_on : col_off);
draw_text(gui_x + 120, st_y + 18, "State: " + recst);
draw_set_color(c_white);
draw_text(gui_x + 235, st_y + 18, "Events: " + string(array_length(global.input_recorder.events)));
