/// obj_input_recorder : Draw GUI

if (!variable_global_exists("editor_on") || !global.editor_on) exit;
if (!variable_global_exists("input_recorder") || !is_struct(global.input_recorder)) exit;

// Never use local names x/y (built-in instance vars)
var xg = ui_x;
var yg = ui_y;
var w  = ui_w;
var h  = ui_h;
var g  = ui_gap;

var col_bg = c_black;
var col_on = c_lime;
var col_off = c_red;

for (var i = 0; i < array_length(box_labels); i++) {
    var bx1 = xg + i * (w + g);
    var by1 = yg;
    var bx2 = bx1 + w;
    var by2 = by1 + h;

    draw_set_alpha(0.67);
    draw_set_color(col_bg);
    draw_roundrect(bx1, by1, bx2, by2, false);

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(bx1 + 10, by1 + 13, string_upper(string(box_labels[i])));
}

var st_y = yg + h + 12;
var is_rec = variable_struct_exists(global.input_recorder, "recording") ? global.input_recorder.recording : false;
var is_on  = variable_struct_exists(global.input_recorder, "enabled") ? global.input_recorder.enabled : true;
var onoff = is_on ? "ON" : "OFF";
var recst = is_rec ? "REC" : "STOP";

var ev_count = 0;
if (variable_struct_exists(global.input_recorder, "events") && is_array(global.input_recorder.events)) {
    ev_count = array_length(global.input_recorder.events);
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_text(xg, st_y, "Input Recorder [F9 toggle, F10 clear]");
draw_text(xg, st_y + 18, "Enabled: " + onoff);

draw_set_color(is_rec ? col_on : col_off);
draw_text(xg + 120, st_y + 18, "State: " + recst);

draw_set_color(c_white);
draw_text(xg + 235, st_y + 18, "Events: " + string(ev_count));
