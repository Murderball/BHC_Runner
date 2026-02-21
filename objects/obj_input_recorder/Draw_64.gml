/// obj_input_recorder : Draw GUI

// --- Editor Mode Check ---
var editor_mode = (variable_global_exists("editor_on") && global.editor_on);
if (!editor_mode) exit;

// --- Input Recorder Struct Check ---
if (!variable_global_exists("input_recorder")) exit;
if (!is_struct(global.input_recorder)) exit;

// --- UI position/sizing ---
// Prefer your existing gui_x/gui_y if you already use them
var gui_x = variable_instance_exists(id, "gui_x") ? gui_x : (variable_instance_exists(id, "ui_x") ? ui_x : 80);
var gui_y = variable_instance_exists(id, "gui_y") ? gui_y : (variable_instance_exists(id, "ui_y") ? ui_y : 120);

var ui_w   = variable_instance_exists(id, "ui_w")   ? ui_w   : 120;
var ui_h   = variable_instance_exists(id, "ui_h")   ? ui_h   : 40;
var ui_gap = variable_instance_exists(id, "ui_gap") ? ui_gap : 10;

// --- Colors ---
var col_bg  = make_color_rgba(0, 0, 0, 170);
var col_on  = make_color_rgb(50, 210, 80);
var col_off = make_color_rgb(170, 70, 70);

// --- Boxes (labels) ---
if (variable_instance_exists(id, "box_labels") && is_array(box_labels))
{
    var n = array_length(box_labels);

    for (var i = 0; i < n; i++)
    {
        var bx1 = gui_x + i * (ui_w + ui_gap);
        var by1 = gui_y;
        var bx2 = bx1 + ui_w;
        var by2 = by1 + ui_h;

        draw_set_alpha(1);
        draw_set_color(col_bg);
        draw_roundrect(bx1, by1, bx2, by2, false);

        draw_set_color(c_white);
        draw_text(bx1 + 10, by1 + 13, string(box_labels[i]));
    }
}
else
{
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(gui_x, gui_y, "obj_input_recorder: box_labels[] not set");
}

// --- Status text ---
var st_y = gui_y + ui_h + 12;

var is_rec = (variable_struct_exists(global.input_recorder, "recording")) ? global.input_recorder.recording : false;
var enabled = (variable_struct_exists(global.input_recorder, "enabled")) ? global.input_recorder.enabled : true;

var onoff = enabled ? "ON" : "OFF";
var recst = is_rec ? "REC" : "STOP";

// Safe events count (don’t directly call array_length on a missing field)
var ev_count = 0;
if (variable_struct_exists(global.input_recorder, "events"))
{
    var ev = global.input_recorder.events;
    if (is_array(ev)) ev_count = array_length(ev);
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_text(gui_x, st_y, "Input Recorder [F9 toggle, F10 clear]");
draw_text(gui_x, st_y + 18, "Enabled: " + onoff);

draw_set_color(is_rec ? col_on : col_off);
draw_text(gui_x + 120, st_y + 18, "State: " + recst);

draw_set_color(c_white);
draw_text(gui_x + 235, st_y + 18, "Events: " + string(ev_count));