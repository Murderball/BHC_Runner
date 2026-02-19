/// obj_chunk_manager : Draw End
/// Debug chunk outlines (2px thick), alternating colors

if (!variable_global_exists("DEBUG_CHUNK_BOXES")) global.DEBUG_CHUNK_BOXES = true;
if (!global.DEBUG_CHUNK_BOXES) exit;

// Chunk size
var chunk_w_px = global.CHUNK_W_TILES * global.TILE_W;
var chunk_h_px = global.CHUNK_H_TILES * global.TILE_H;

// Same offset your chunk system uses
var xoff = variable_global_exists("CHUNK_X_OFFSET_PX") ? global.CHUNK_X_OFFSET_PX : 0;

// Colors
var col_green  = make_color_rgb(0, 255, 0);
var col_purple = make_color_rgb(180, 0, 255);

draw_set_alpha(1);

for (var slot = 0; slot < buffer_chunks; slot++)
{
    var x1 = (slot * chunk_w_px) - xoff;
    var y1 = 0;
    var x2 = x1 + chunk_w_px;
    var y2 = y1 + chunk_h_px;

    draw_set_colour((slot & 1) == 0 ? col_green : col_purple);

    // ---------
    // 2px outline: draw twice with 1px offsets
    // ---------
    draw_rectangle(x1,     y1,     x2,     y2,     true);
    draw_rectangle(x1 + 1, y1 + 1, x2 - 1, y2 - 1, true);
}

draw_set_colour(c_black);
draw_set_alpha(1);
