function scr_tilemaps_init()
{
    // --- Layer name constants (use THESE everywhere) ---
    global.LYR_VIS_EASY_NAME   = "TL_Visual_Easy";
    global.LYR_VIS_NORMAL_NAME = "TL_Visual_Normal";
    global.LYR_VIS_HARD_NAME   = "TL_Visual_Hard";
    global.LYR_COLLIDE_NAME    = "TL_Collide";

    // --- Reset ids ---
    global.layer_vis_easy_id   = -1;
    global.layer_vis_normal_id = -1;
    global.layer_vis_hard_id   = -1;
    global.layer_collide_id    = -1;

    global.tm_vis_easy   = -1;
    global.tm_vis_normal = -1;
    global.tm_vis_hard   = -1;
    global.tm_collide    = -1;

    // --- Fetch layers + tilemaps (room must have these TILE layers) ---
    global.layer_vis_easy_id   = layer_get_id(global.LYR_VIS_EASY_NAME);
    global.layer_vis_normal_id = layer_get_id(global.LYR_VIS_NORMAL_NAME);
    global.layer_vis_hard_id   = layer_get_id(global.LYR_VIS_HARD_NAME);
    global.layer_collide_id    = layer_get_id(global.LYR_COLLIDE_NAME);

    if (global.layer_vis_easy_id   != -1) global.tm_vis_easy   = layer_tilemap_get_id(global.layer_vis_easy_id);
    if (global.layer_vis_normal_id != -1) global.tm_vis_normal = layer_tilemap_get_id(global.layer_vis_normal_id);
    if (global.layer_vis_hard_id   != -1) global.tm_vis_hard   = layer_tilemap_get_id(global.layer_vis_hard_id);
    if (global.layer_collide_id    != -1) global.tm_collide    = layer_tilemap_get_id(global.layer_collide_id);

    // --- Preview layers (optional) ---
    global.layer_prev_vis_id = layer_get_id("TL_Preview_Visual");
    global.layer_prev_col_id = layer_get_id("TL_Preview_Collide");

    global.tm_prev_visual  = (global.layer_prev_vis_id != -1) ? layer_tilemap_get_id(global.layer_prev_vis_id) : -1;
    global.tm_prev_collide = (global.layer_prev_col_id != -1) ? layer_tilemap_get_id(global.layer_prev_col_id) : -1;

    // --- Tile size ---
    global.TILE_W = 32;
    global.TILE_H = 32;

    // ------------------------------------------------------------------
    // CRITICAL FIX:
    // Some rooms (rm_level03 in your project) have TL_Visual_Hard with
    // tilesetId = null in the .yy, which means the tilemap cannot draw.
    // Force-assign tilesets at runtime if missing.
    // ------------------------------------------------------------------
    var tsE = asset_get_index("TileSet_Easy");
    var tsN = asset_get_index("TileSet_Normal");
    var tsH = asset_get_index("TileSet_Hard");

    // Helper: if the tilemap has no tileset, set it.
    // tilemap_get_tileset returns the tileset index (or -1/0 depending on state).
    if (global.tm_vis_easy != -1 && tsE != -1) {
        var curE = tilemap_get_tileset(global.tm_vis_easy);
        if (curE <= 0) tilemap_set_tileset(global.tm_vis_easy, tsE);
    }

    if (global.tm_vis_normal != -1 && tsN != -1) {
        var curN = tilemap_get_tileset(global.tm_vis_normal);
        if (curN <= 0) tilemap_set_tileset(global.tm_vis_normal, tsN);
    }

    if (global.tm_vis_hard != -1 && tsH != -1) {
        var curH = tilemap_get_tileset(global.tm_vis_hard);
        if (curH <= 0) tilemap_set_tileset(global.tm_vis_hard, tsH);
    }

    // --- (Optional) compatibility for any remaining legacy code ---
    // Do NOT rely on these long term. This just prevents old checks from exiting.
    global.tm_visual  = global.tm_vis_normal; // legacy "visual" = normal
}
