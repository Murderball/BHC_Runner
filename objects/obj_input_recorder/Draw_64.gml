/// obj_input_recorder : Draw GUI

if (!variable_global_exists("editor_on") || !global.editor_on) exit;
if (!variable_global_exists("input_recorder") || !is_struct(global.input_recorder)) exit;

var xg = ui_x;
var yg = ui_y;

var labels = ["JUMP (SPACE)", "DUCK (SHIFT)", "ATK1 (1)", "ATK2 (2)", "ATK3 (3)", "ULT (4)"];
var active = [
    keyboard_check(vk_space),
    keyboard_check(vk_shift),
    keyboard_check(ord("1")),
    keyboard_check(ord("2")),
    keyboard_check(ord("3")),
    keyboard_check(ord("4"))
];

var col_on_fill = make_color_rgb(70, 170, 90);
var col_on_text = c_black;
var col_off_fill = make_color_rgb(30, 30, 30);
var col_off_text = c_white;

var n = array_length(labels);
for (var i = 0; i < n; i++)
{
    var bx1 = xg + i * (ui_w + ui_gap);
    var by1 = yg;
    var bx2 = bx1 + ui_w;
    var by2 = by1 + ui_h;

    var is_on = active[i];

    draw_set_alpha(is_on ? 0.95 : 0.80);
    draw_set_color(is_on ? col_on_fill : col_off_fill);
    draw_roundrect(bx1, by1, bx2, by2, false);

    draw_set_alpha(1);
    draw_set_color(is_on ? col_on_text : col_off_text);
    draw_text(bx1 + 8, by1 + 13, labels[i]);
}

var st_y = yg + ui_h + 12;

var is_rec = (variable_struct_exists(global.input_recorder, "recording")) ? global.input_recorder.recording : false;
var enabled = (variable_struct_exists(global.input_recorder, "enabled")) ? global.input_recorder.enabled : true;

var onoff = enabled ? "ON" : "OFF";
var recst = is_rec ? "REC" : "STOP";

var ev_count = 0;
if (variable_struct_exists(global.input_recorder, "events") && is_array(global.input_recorder.events)) {
    ev_count = array_length(global.input_recorder.events);
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_text(xg, st_y, "Input Recorder [F9 toggle, F10 clear]");
draw_text(xg, st_y + 18, "Enabled: " + onoff);

draw_set_color(is_rec ? make_color_rgb(50, 210, 80) : make_color_rgb(170, 70, 70));
draw_text(xg + 120, st_y + 18, "State: " + recst);

draw_set_color(c_white);
draw_text(xg + 235, st_y + 18, "Events: " + string(ev_count));
