function scr_chunk_system_init() {
    // Tile + chunk constants (authoritative)
    global.TILE_W = 32;
    global.TILE_H = 32;

    // Beat lock math:
    // BPM 140 => 1 beat = 60/140 = 0.428571s
    // WORLD_PPS 448 => pixels per beat = 448 * 0.428571 = 192px
    // With 32px tiles => 192/32 = 6 tiles per beat
    // 4 beats (1 bar) => 24 tiles
    global.CHUNK_W_TILES = 24;

    // Keep your old pixel height (~1088px) but in 32px tiles:
    // 1088 / 32 = 34
    global.CHUNK_H_TILES = 34;

    // Stream settings
    global.BUFFER_CHUNKS   = 120;
    global.SPAWN_AHEAD     = 10;
    global.DESPAWN_BEHIND  = 10;

    // Hitline in pixels from camera-left
    global.HITLINE_X = 448;

    if (!variable_global_exists("WORLD_PPS")) global.WORLD_PPS = 448;
}
