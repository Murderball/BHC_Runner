/// obj_upgrade_pillar : Step

// ----------------------------------------------------
// Mouse position in ROOM space (correct for world objects)
// ----------------------------------------------------
var mx = device_mouse_x(0);
var my = device_mouse_y(0);

// Hover check (room-space bbox_*)
hovered = point_in_rectangle(
    mx, my,
    bbox_left, bbox_top,
    bbox_right, bbox_bottom
);

// Click
if (hovered && mouse_check_button_pressed(mb_left))
{
    show_debug_message("Upgrade pillar activated");
    // open upgrade UI here
}

// Smooth fade
var target = hovered ? 1 : 0;
glow_alpha = lerp(glow_alpha, target, 0.2);
