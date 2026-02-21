/// obj_input_recorder : Draw GUI

var editor_mode = (variable_global_exists("editor_on") && global.editor_on);
if (!editor_mode) exit;
if (!variable_global_exists("input_recorder") || !is_struct(global.input_recorder)) exit;

// Never use local names x/y (built-in instance vars)
var xg = variable_instance_exists(id, "ui_x") ? ui_x : 80;
var yg = variable_instance_exists(id, "ui_y") ? ui_y : 120;
var w  = variable_instance_exists(id, "ui_w") ? ui_w : 110;
var h  = variable_instance_exists(id, "ui_h") ? ui_h : 44;
var g  = variable_instance_exists(id, "ui_gap") ? ui_gap : 8;

var col_bg = c_black;
var col_on = c_lime;
var col_off = c_red;

if (variable_instance_exists(id, "box_labels") && is_array(box_labels)) {
    var n = array_length(box_labels);
    for (var i = 0; i < n; i++) {
        var bx1 = xg + i * (w + g);
        var by1 = yg;
        var bx2 = bx1 + w;
        var by2 = by1 + h;

        draw_set_alpha(0.67);
        draw_set_color(col_bg);
        draw_roundrect(bx1, by1, bx2, by2, false);

        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(bx1 + 10, by1 + 13, string(box_labels[i]));
    }
} else {
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(xg, yg, "obj_input_recorder: box_labels[] not set");
}

var st_y = yg + h + 12;
var is_rec = variable_struct_exists(global.input_recorder, "recording") ? global.input_recorder.recording : false;
var is_on  = variable_struct_exists(global.input_recorder, "enabled") ? global.input_recorder.enabled : true;
var onoff = is_on ? "ON" : "OFF";
var recst = is_rec ? "REC" : "STOP";

var ev_count = 0;
if (variable_struct_exists(global.input_recorder, "events")) {
    var ev = global.input_recorder.events;
    if (is_array(ev)) ev_count = array_length(ev);
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_text(xg, st_y, "Input Recorder [F9 toggle, F10 clear]");
draw_text(xg, st_y + 18, "Enabled: " + onoff);

draw_set_color(is_rec ? col_on : col_off);
draw_text(xg + 120, st_y + 18, "State: " + recst);

draw_set_color(c_white);
draw_text(xg + 235, st_y + 18, "Events: " + string(ev_count));
