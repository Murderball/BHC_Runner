/// scr_chunk_stamp_slot_step(job)
/// job = { chunk_data, slot, ci, row, rows_per_step }
/// Incremental stamper:
/// - Always stamps collide
/// - In editor: stamps Easy+Normal+Hard visuals
/// - In gameplay: stamps ONLY current difficulty visual
/// Returns true when finished.

function scr_chunk_stamp_slot_step(job)
{
    // ---- read job ----
    var data = undefined;
    if (is_struct(job))
    {
        if (variable_struct_exists(job, "data"))            data = job.data;
        else if (variable_struct_exists(job, "chunk_data")) data = job.chunk_data;
    }
    if (is_undefined(data)) return true; // drop safely

    var slot = (variable_struct_exists(job, "slot") ? job.slot : 0);

    if (!variable_struct_exists(job, "row") || !is_real(job.row) || is_nan(job.row)) job.row = 0;

    var rows_per_step = (variable_struct_exists(job, "rows_per_step") ? job.rows_per_step : 8);
    if (!is_real(rows_per_step) || is_nan(rows_per_step) || rows_per_step < 1) rows_per_step = 8;

    // ---- dimensions ----
    var src_w = data.w;
    var src_h = data.h;

    var dst_w = global.CHUNK_W_TILES;
    var dst_h = global.CHUNK_H_TILES;

    var base_tx = slot * dst_w;

    var w = min(src_w, dst_w);
    var h = min(src_h, dst_h);

    var y0 = job.row;
    var y1 = min(y0 + rows_per_step, h);

    // ---- arrays ----
    if (!variable_struct_exists(data, "col")) return true;
    var col = data.col;

    var hasE = variable_struct_exists(data, "vis_easy");
    var hasN = variable_struct_exists(data, "vis_normal");
    var hasH = variable_struct_exists(data, "vis_hard");

    var visE = hasE ? data.vis_easy   : undefined;
    var visN = hasN ? data.vis_normal : undefined;
    var visH = hasH ? data.vis_hard   : undefined;

    // ---- tilemaps ----
    var tmC = (variable_global_exists("tm_collide") ? global.tm_collide : -1);
    if (tmC == -1) return true;

    var tmE = (variable_global_exists("tm_vis_easy")   ? global.tm_vis_easy   : -1);
    var tmN = (variable_global_exists("tm_vis_normal") ? global.tm_vis_normal : -1);
    var tmH = (variable_global_exists("tm_vis_hard")   ? global.tm_vis_hard   : -1);

    var ed_on = (variable_global_exists("editor_on") && global.editor_on);

    // gameplay chooses ONE visual layer
    var diff = "normal";
    if (variable_global_exists("difficulty")) diff = string_lower(string(global.difficulty));
    else if (variable_global_exists("DIFFICULTY")) diff = string_lower(string(global.DIFFICULTY));

    var do_game_vis = (!ed_on);

    // ---- stamp slice ----
    for (var ty = y0; ty < y1; ty++)
    {
        for (var tx = 0; tx < w; tx++)
        {
            var src_idx = tx + ty * src_w;
            var dst_x = base_tx + tx;

            // collide always
            tilemap_set(tmC, col[src_idx], dst_x, ty);

            if (ed_on)
            {
                if (tmE != -1 && !is_undefined(visE)) tilemap_set(tmE, visE[src_idx], dst_x, ty);
                if (tmN != -1 && !is_undefined(visN)) tilemap_set(tmN, visN[src_idx], dst_x, ty);
                if (tmH != -1 && !is_undefined(visH)) tilemap_set(tmH, visH[src_idx], dst_x, ty);
            }
            else if (do_game_vis)
            {
                if (diff == "easy" && tmE != -1 && !is_undefined(visE)) tilemap_set(tmE, visE[src_idx], dst_x, ty);
                else if (diff == "hard" && tmH != -1 && !is_undefined(visH)) tilemap_set(tmH, visH[src_idx], dst_x, ty);
                else if (tmN != -1 && !is_undefined(visN)) tilemap_set(tmN, visN[src_idx], dst_x, ty);
            }
        }
    }

    job.row = y1;
    return (job.row >= h);
}