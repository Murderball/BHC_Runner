function scr_chunk_stamp_room(data)
{
    if (is_undefined(data)) return false;

    var layer_vis = layer_get_id("TL_Visual");
    var layer_col = layer_get_id("TL_Collide");

    if (layer_vis == -1 || layer_col == -1) {
        show_debug_message("[chunk_import] Missing TL_Visual or TL_Collide layer");
        return false;
    }

    var tm_vis = layer_tilemap_get_id(layer_vis);
    var tm_col = layer_tilemap_get_id(layer_col);

    if (tm_vis == -1 || tm_col == -1) {
        show_debug_message("[chunk_import] TL_Visual/TL_Collide are not tile layers");
        return false;
    }

    if (!variable_struct_exists(data, "vis") || !variable_struct_exists(data, "col")) {
        show_debug_message("[chunk_import] JSON missing vis/col arrays");
        return false;
    }

    // JSON dimensions (preferred if present)
    var jw = variable_struct_exists(data, "w") ? data.w : global.CHUNK_W_TILES;
    var jh = variable_struct_exists(data, "h") ? data.h : global.CHUNK_H_TILES;

    // Room tilemap dimensions (actual)
    var rw = tilemap_get_width(tm_vis);
    var rh = tilemap_get_height(tm_vis);

    // Stamp only what fits in the room tilemap
    var w = min(jw, rw);
    var h = min(jh, rh);

    var vis_arr = data.vis;
    var col_arr = data.col;

    // Row-major: i = x + y * jw (JSON stride!)
    for (var yy = 0; yy < h; yy++) {
        for (var xx = 0; xx < w; xx++) {

            var i = xx + yy * jw; // IMPORTANT: stride by JSON width
            if (i < 0 || i >= array_length(vis_arr)) continue;

            tilemap_set(tm_vis, vis_arr[i], xx, yy);
            tilemap_set(tm_col, col_arr[i], xx, yy);
        }
    }

    return true;
}
