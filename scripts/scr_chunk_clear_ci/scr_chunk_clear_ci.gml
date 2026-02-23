function scr_chunk_clear_ci(ci) {
    if (global.tm_visual == -1 || global.tm_collide == -1) return;

    var base_tx = ci * global.CHUNK_W_TILES;

    for (var ty = 0; ty < global.CHUNK_H_TILES; ty++) {
        for (var tx = 0; tx < global.CHUNK_W_TILES; tx++) {
            tilemap_set(global.tm_visual,  0, base_tx + tx, ty);
            tilemap_set(global.tm_collide, 0, base_tx + tx, ty);
        }
    }
}
