/// obj_bg_manager : Draw (PAINTED TO CHUNKS) — no inner function

var cam = view_camera[0];
var cx  = camera_get_view_x(cam);
var cy  = camera_get_view_y(cam);
var vw  = camera_get_view_width(cam);
var vh  = camera_get_view_height(cam);

var chunk_w_px = global.CHUNK_W_TILES * global.TILE_W;
var strip_w_px = global.BUFFER_CHUNKS * chunk_w_px;

// Parallax scroll source
var x_abs = (variable_global_exists("WORLD_X_ABS")) ? global.WORLD_X_ABS : cx;

// Camera position in BG-space (ring wrapped)
var cam_bg = (x_abs * parallax) mod strip_w_px;
if (cam_bg < 0) cam_bg += strip_w_px;

// Draw each slot's painted sprite across its chunk width
for (var slot = 0; slot < global.BUFFER_CHUNKS; slot++)
{
    // Choose which painted array this manager uses
    // Near by default; set bg_profile="far" on the far instance
    var spr = -1;
    if (variable_instance_exists(id, "bg_profile") && bg_profile == "far")
        spr = global.bg_slot_far[slot];
    else
        spr = global.bg_slot_near[slot];

    if (spr == -1) spr = spr_bg_easy_00;

    // BG-space x for this slot
    var bgx = slot * chunk_w_px;

    // Convert BG-space X -> room-space X so the camera at cx sees the correct bg:
    // x_room = (bgx - cam_bg) + cx
    var x1 = (bgx - cam_bg) + cx;

    // Wrap coverage: draw 3 copies so edges never pop
    for (var k = -1; k <= 1; k++)
    {
        var xw = x1 + k * strip_w_px;

        // Quick cull
        if (xw > cx + vw + chunk_w_px) continue;
        if (xw < cx - chunk_w_px) continue;

        draw_sprite_stretched(spr, 0, xw, cy, chunk_w_px, vh);
    }
}