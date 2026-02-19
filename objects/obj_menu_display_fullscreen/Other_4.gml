/// obj_menu_display_fullscreen : Room Start
/// Fullscreen menu display while keeping 1366x768 camera for panning

var VIEW_W = 1366;
var VIEW_H = 768;

// Your intended camera view stays fixed:
view_enabled = true;
view_visible[0] = true;

view_wview[0] = VIEW_W;
view_hview[0] = VIEW_H;

// Make window fullscreen
if (!window_get_fullscreen()) window_set_fullscreen(true);

// Get the fullscreen backbuffer size
var SW = display_get_width();
var SH = display_get_height();

// Fit VIEW into screen with aspect preserved (letterbox/pillarbox)
var sx = SW / VIEW_W;
var sy = SH / VIEW_H;
var s  = min(sx, sy);

var port_w = floor(VIEW_W * s);
var port_h = floor(VIEW_H * s);
var port_x = floor((SW - port_w) * 0.5);
var port_y = floor((SH - port_h) * 0.5);

// Apply to viewport 0 (port = screen, view = camera)
view_wport[0] = port_w;
view_hport[0] = port_h;
view_xport[0] = port_x;
view_yport[0] = port_y;

// GUI should match the camera size so your UI coordinates stay consistent
display_set_gui_size(VIEW_W, VIEW_H);

// Ensure camera matches the view size
var cam = view_camera[0];
if (cam != noone) {
    camera_set_view_size(cam, VIEW_W, VIEW_H);
}

// Optional: black bars look correct
application_surface_draw_enable(true);
