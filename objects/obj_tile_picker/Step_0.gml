/// obj_tile_picker : Step
/// Toggle with P. Click to print tiledata from the ACTIVE difficulty visual tilemap.

if (keyboard_check_pressed(ord("P"))) show = !show;
if (!show) exit;

// Determine which visual tilemap to sample
var d = "normal";
if (variable_global_exists("DIFFICULTY")) d = string_lower(string(global.DIFFICULTY));
else if (variable_global_exists("difficulty")) d = string_lower(string(global.difficulty));

var tm = -1;
if (d == "easy") {
    if (variable_global_exists("tm_vis_easy")) tm = global.tm_vis_easy;
} else if (d == "hard") {
    if (variable_global_exists("tm_vis_hard")) tm = global.tm_vis_hard;
} else {
    if (variable_global_exists("tm_vis_normal")) tm = global.tm_vis_normal;
}

// Fallback to legacy tm_visual if needed
if (tm == -1 && variable_global_exists("tm_visual")) tm = global.tm_visual;

// Click a tile in the room to print its tiledata
if (mouse_check_button_pressed(mb_left))
{
    var cam = view_camera[0];
    var wx = camera_get_view_x(cam) + device_mouse_x_to_gui(0);
    var wy = camera_get_view_y(cam) + device_mouse_y_to_gui(0);

    var td = tilemap_get_at_pixel(tm, wx, wy);

    show_debug_message("[tile_picker] diff=" + d
        + " tm=" + string(tm)
        + " at (" + string(wx) + "," + string(wy) + ") = " + string(td));
}