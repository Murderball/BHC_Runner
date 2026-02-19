// obj_camera : Room Start
// Ensure tilemaps are re-captured for THIS room (critical for boss rooms that lack obj_game)
if (script_exists(scr_tilemaps_init)) {
    scr_tilemaps_init();
}

// Clamp view into this room on entry (prevents snap weirdness)
var cam = view_camera[0];

var vw = camera_get_view_width(cam);
var vh = camera_get_view_height(cam);

var max_x = max(0, room_width  - vw);
var max_y = max(0, room_height - vh);

cam_world_x = clamp(cam_world_x, 0, max_x);
cam_world_y = clamp(cam_world_y, 0, max_y);

camera_set_view_pos(cam, cam_world_x, cam_world_y);
