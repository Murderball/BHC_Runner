/// scr_apply_viewport_fit(view_w, view_h)
/// Re-applies viewport + GUI scaling (letterbox) to the current window/screen.
/// Use this any time you return from menu/fullscreen UI to gameplay.

function scr_apply_viewport_fit(_view_w, _view_h)
{
    // Ensure view 0 is enabled
    view_enabled = true;
    view_visible[0] = true;

    // Keep camera 0 aligned to the intended logical view size
    var cam = view_camera[0];
    if (cam != noone) camera_set_view_size(cam, _view_w, _view_h);

    // Determine backbuffer size
    var SW, SH;
    if (window_get_fullscreen()) {
        SW = display_get_width();
        SH = display_get_height();
    } else {
        SW = window_get_width();
        SH = window_get_height();
    }

    // Fit while preserving aspect ratio (letterbox / pillarbox)
    var sx = SW / _view_w;
    var sy = SH / _view_h;
    var s  = min(sx, sy);

    var port_w = floor(_view_w * s);
    var port_h = floor(_view_h * s);
    var port_x = floor((SW - port_w) * 0.5);
    var port_y = floor((SH - port_h) * 0.5);

    // Apply viewport (screen space)
    view_wport[0] = port_w;
    view_hport[0] = port_h;
    view_xport[0] = port_x;
    view_yport[0] = port_y;

    // GUI space must match gameplay design coords
    display_set_gui_size(_view_w, _view_h);

    // Keep application surface enabled and drawable.
    application_surface_enable(true);
    application_surface_draw_enable(true);
}
