/// obj_input_recorder : Draw GUI

// --- Editor Mode Check ---
var editor_mode = false;

if (variable_global_exists("editor_on"))
{
    editor_mode = global.editor_on;
}

if (!editor_mode) exit;

// --- Input Recorder Struct Check ---
if (!variable_global_exists("input_recorder")) exit;
if (!is_struct(global.input_recorder)) exit;

// --- UI Position (safe fallback) ---
// NOTE: don't use local vars named x/y (built-ins)
var xg = 0;
var yg = 0;

if (variable_instance_exists(id, "ui_x")) xg = ui_x;
if (variable_instance_exists(id, "ui_y")) yg = ui_y;

// Optional default placement if you haven't set ui_x/ui_y yet
if (xg == 0 && yg == 0) {
    xg = 80;
    yg = 120;
}

// --- UI sizing fallbacks (in case not defined on instance) ---
var w   = variable_instance_exists(id, "ui_w")   ? ui_w   : 120;
var h   = variable_instance_exists(id, "ui_h")   ? ui_h   : 40;
var gap = variable_instance_exists(id, "ui_gap") ? ui_gap : 10;

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
        var bx1 = xg + i * (w + gap);
        var by1 = yg;
        var bx2 = bx1 + w;
        var by2 = by1 + h;

        draw_set_alpha(1);
        draw_set_color(col_bg);
        draw_roundrect(bx1, by1, bx2, by2, false);

        draw_set_color(c_white);
        draw_text(bx1 + 10, by1 + 13, string(box_labels[i]));
    }
}
else
{
    // If labels aren't set yet, show a helpful editor hint instead of crashing
    draw_set_color(c_white);
    draw_text(xg, yg, "obj_input_recorder: box_labels[] not set");
}

// --- Status text ---
var st_y = yg + h + 12;

// These fields should exist, but guard anyway
var is_rec = false;
if (variable_struct_exists(global.input_recorder, "recording")) is_rec = global.input_recorder.recording;

var enabled = true;
if (variable_struct_exists(global.input_recorder, "enabled")) enabled = global.input_recorder.enabled;

var onoff = enabled ? "ON" : "OFF";
var recst = is_rec ? "REC" : "STOP";

// events length safe
var ev_count = 0;
if (variable_struct_exists(global.input_recorder, "events") && is_array(global.input_recorder.events)) {
    ev_count = array_length(global.input_recorder.events);
}

draw_set_color(c_white);
draw_text(xg, st_y, "Input Recorder [F9 toggle, F10 clear]");
draw_text(xg, st_y + 18, "Enabled: " + onoff);

draw_set_color(is_rec ? col_on : col_off);
draw_text(xg + 120, st_y + 18, "State: " + recst);

draw_set_color(c_white);
draw_text(xg + 235, st_y + 18, "Events: " + string(ev_count));