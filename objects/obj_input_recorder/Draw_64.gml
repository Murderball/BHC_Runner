/// obj_input_recorder : Draw GUI

editor_mode = (variable_global_exists("editor_on") && global.editor_on);
if (!editor_mode) exit;
if (!variable_global_exists("input_recorder") || !is_struct(global.input_recorder)) exit;

var x = ui_x;
var y = ui_y;

var col_bg = make_color_rgba(0, 0, 0, 170);
var col_on = make_color_rgb(50, 210, 80);
var col_off = make_color_rgb(170, 70, 70);

for (var i = 0; i < array_length(box_labels); i++) {
    var bx1 = x + i * (ui_w + ui_gap);
    var by1 = y;
    var bx2 = bx1 + ui_w;
    var by2 = by1 + ui_h;

    draw_set_alpha(1);
    draw_set_color(col_bg);
    draw_roundrect(bx1, by1, bx2, by2, false);

    draw_set_color(c_white);
    draw_text(bx1 + 10, by1 + 13, box_labels[i]);
}

var st_y = y + ui_h + 12;
var is_rec = global.input_recorder.recording;
var onoff = global.input_recorder.enabled ? "ON" : "OFF";
var recst = is_rec ? "REC" : "STOP";

draw_set_color(c_white);
draw_text(x, st_y, "Input Recorder [F9 toggle, F10 clear]");
draw_text(x, st_y + 18, "Enabled: " + onoff);
draw_set_color(is_rec ? col_on : col_off);
draw_text(x + 120, st_y + 18, "State: " + recst);
draw_set_color(c_white);
draw_text(x + 235, st_y + 18, "Events: " + string(array_length(global.input_recorder.events)));
