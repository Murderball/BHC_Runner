// ------------------------------------------------------------
// SAFETY: ensure base resolution exists even if obj_camera
// ------------------------------------------------------------
if (!variable_global_exists("BASE_W")) global.BASE_W = 1920;
if (!variable_global_exists("BASE_H")) global.BASE_H = 1080;

base_w = global.BASE_W;
base_h = global.BASE_H;

// Camera zoom setup
cam_zoom = 1.0;
cam_zoom_min = 0.5;
cam_zoom_max = 2.5;

smooth = 0.12;
cam_world_x = 0;
cam_world_y = 0;

// Base view size (used for zoom math)
view_base_w = global.BASE_W;
view_base_h = global.BASE_H;

// IMPORTANT: Destroy any existing camera on view 0 to avoid leftovers
if (view_camera[0] != noone) {
    // It's safe to destroy if it's a runtime camera id
    camera_destroy(view_camera[0]);
    view_camera[0] = noone;
}

// Create camera using base resolution
var cam_id = camera_create_view(
    0, 0,
    global.BASE_W, global.BASE_H,
    0,
    noone,
    -1, -1, -1, -1
);

// Assign to viewport 0
view_camera[0] = cam_id;

// Enable viewport 0
view_enabled = true;
view_visible[0] = true;

// Apply correct GAMEPLAY viewport + GUI scaling (overrides menu)
if (script_exists(scr_apply_viewport_fit)) {
    scr_apply_viewport_fit(global.BASE_W, global.BASE_H);
} else {
    // Fallback (no letterbox)
    view_xport[0] = 0;
    view_yport[0] = 0;
    view_wport[0] = global.BASE_W;
    view_hport[0] = global.BASE_H;
    display_set_gui_size(global.BASE_W, global.BASE_H);
    application_surface_draw_enable(true);
}
