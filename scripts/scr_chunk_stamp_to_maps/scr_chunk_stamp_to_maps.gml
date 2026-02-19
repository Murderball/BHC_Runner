/// scr_chunk_stamp_to_maps(chunk_data, slot, tm_vis_id, tm_col_id)
/// Backward compatible signature:
/// - Older callers pass (chunk_data, slot, tm_vis_id, tm_col_id)
/// - Newer code can pass just (chunk_data, slot) and leave the rest unused
///
/// Writes:
/// - collide -> tm_col_id if provided, else global.tm_collide
/// - visuals -> EASY/NORMAL/HARD global tilemaps if available
///   If only legacy chunk_data.vis exists, it is used for all 3.

function scr_chunk_stamp_to_maps(chunk_data, slot, tm_vis_id, tm_col_id)
{
    if (is_undefined(chunk_data)) return;

    // Resolve destination tilemaps
    var tmC = is_real(tm_col_id) ? tm_col_id : (variable_global_exists("tm_collide") ? global.tm_collide : -1);

    // We no longer use tm_vis_id (single layer) for difficulty A-mode.
    // But keep it for compatibility: if you *don't* have the 3 maps, we’ll stamp into tm_vis_id.
    var tmSingle = is_real(tm_vis_id) ? tm_vis_id : -1;

    var tmE = (variable_global_exists("tm_vis_easy")   ? global.tm_vis_easy   : -1);
    var tmN = (variable_global_exists("tm_vis_normal") ? global.tm_vis_normal : -1);
    var tmH = (variable_global_exists("tm_vis_hard")   ? global.tm_vis_hard   : -1);

    if (tmC == -1) return;

    // Source dims
    var src_w = chunk_data.w;
    var src_h = chunk_data.h;

    // Dest dims (authoritative)
    var dst_w = global.CHUNK_W_TILES;
    var dst_h = global.CHUNK_H_TILES;

    // Slot origin in destination tilemap
    var base_tx = slot * dst_w;

    // Stamp cropped
    var w = min(src_w, dst_w);
    var h = min(src_h, dst_h);

    // Arrays: collide must exist
    var arrC = chunk_data.col;

    // Visual arrays:
    // Prefer new fields; fall back to legacy 'vis'
    var arrE = undefined;
    var arrN = undefined;
    var arrH = undefined;

    if (variable_struct_exists(chunk_data, "vis_easy"))   arrE = chunk_data.vis_easy;
    if (variable_struct_exists(chunk_data, "vis_normal")) arrN = chunk_data.vis_normal;
    if (variable_struct_exists(chunk_data, "vis_hard"))   arrH = chunk_data.vis_hard;

    if (is_undefined(arrE) || is_undefined(arrN) || is_undefined(arrH))
    {
        if (variable_struct_exists(chunk_data, "vis")) {
            arrE = chunk_data.vis;
            arrN = chunk_data.vis;
            arrH = chunk_data.vis;
        }
    }

    for (var ty = 0; ty < h; ty++)
    {
        for (var tx = 0; tx < w; tx++)
        {
            var src_idx = tx + ty * src_w;
            var dst_x = base_tx + tx;

            // collide always
            tilemap_set(tmC, arrC[src_idx], dst_x, ty);

            // If we have 3 tilemaps, stamp them
            if (tmE != -1 && !is_undefined(arrE)) tilemap_set(tmE, arrE[src_idx], dst_x, ty);
            if (tmN != -1 && !is_undefined(arrN)) tilemap_set(tmN, arrN[src_idx], dst_x, ty);
            if (tmH != -1 && !is_undefined(arrH)) tilemap_set(tmH, arrH[src_idx], dst_x, ty);

            // If 3 maps are missing but legacy single visual tilemap exists, stamp it
            if (tmE == -1 && tmN == -1 && tmH == -1 && tmSingle != -1 && variable_struct_exists(chunk_data, "vis")) {
                tilemap_set(tmSingle, chunk_data.vis[src_idx], dst_x, ty);
            }
        }
    }
}