function scr_chunk_clear_room()
{
    var layer_vis = layer_get_id("TL_Visual");
    var layer_col = layer_get_id("TL_Collide");

    if (layer_vis == -1 || layer_col == -1) {
        show_debug_message("[scr_chunk_clear_room] Missing TL_Visual or TL_Collide layer.");
        return false;
    }

    var tm_vis = layer_tilemap_get_id(layer_vis);
    var tm_col = layer_tilemap_get_id(layer_col);

    if (tm_vis == -1 || tm_col == -1) {
        show_debug_message("[scr_chunk_clear_room] TL_Visual/TL_Collide are not tile layers.");
        return false;
    }

    // Use ACTUAL tilemap dimensions
    var w = tilemap_get_width(tm_vis);
    var h = tilemap_get_height(tm_vis);

    for (var yy = 0; yy < h; yy++) {
        for (var xx = 0; xx < w; xx++) {
            tilemap_set(tm_vis, 0, xx, yy);
            tilemap_set(tm_col, 0, xx, yy);
        }
    }

    return true;
}
