function scr_chunk_stamp_step(max_rows)
{
    if (array_length(global.chunk_stamp_queue) == 0) return;

    var job = global.chunk_stamp_queue[0];
    var chunk = job.chunk;

    var src_w = chunk.w;
    var src_h = chunk.h;
    var dst_w = global.CHUNK_W_TILES;
    var base_tx = job.slot * dst_w;

    var rows = 0;

    while (job.ty < src_h && rows < max_rows)
    {
        var ty = job.ty;

        for (var tx = 0; tx < src_w; tx++)
        {
            var idx = tx + ty * src_w;
            tilemap_set(global.tm_collide, chunk.col[idx], base_tx + tx, ty);
            tilemap_set(global.tm_vis_normal, chunk.vis_normal[idx], base_tx + tx, ty);
        }

        job.ty++;
        rows++;
    }

    if (job.ty >= src_h)
    {
        array_delete(global.chunk_stamp_queue, 0, 1);
    }
}