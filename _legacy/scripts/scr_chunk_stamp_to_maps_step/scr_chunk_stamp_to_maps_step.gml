/// scr_chunk_stamp_to_maps_step(job)
/// job = { chunk_data, slot, row, rows_per_step, tm_vis_id?, tm_col_id? }
/// Backward compatible with your stamp_to_maps rules.
/// Returns true when finished.

function scr_chunk_stamp_to_maps_step(job)
{
    var __mp = (script_exists(scr_microprof_begin) ? scr_microprof_begin("chunk.tile_stamp") : 0);
    var chunk_data = job.chunk_data;
    if (is_undefined(chunk_data)) { if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.tile_stamp", __mp); return true; }

    var slot = job.slot;

    // Resolve destination tilemaps (same rules as your full stamper)
    var tmC = is_real(job.tm_col_id) ? job.tm_col_id : (variable_global_exists("tm_collide") ? global.tm_collide : -1);

    var tmSingle = is_real(job.tm_vis_id) ? job.tm_vis_id : -1;

    var tmE = (variable_global_exists("tm_vis_easy")   ? global.tm_vis_easy   : -1);
    var tmN = (variable_global_exists("tm_vis_normal") ? global.tm_vis_normal : -1);
    var tmH = (variable_global_exists("tm_vis_hard")   ? global.tm_vis_hard   : -1);

    if (tmC == -1) { if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.tile_stamp", __mp); return true; }

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
    if (!is_array(arrC)) { if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.tile_stamp", __mp); return true; }

    // Visual arrays: prefer new fields; fallback to legacy 'vis'
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

    // Row range this step
    var y0 = job.row;
    var y1 = min(y0 + job.rows_per_step, h);

    for (var ty = y0; ty < y1; ty++)
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

    job.row = y1;
    if (script_exists(scr_microprof_end)) scr_microprof_end("chunk.tile_stamp", __mp);
    return (job.row >= h);
}