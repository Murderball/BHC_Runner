/// scr_visual_bands_init()
/// Builds tile index offsets for the 3 vertical bands in the master tileset sprite.
function scr_visual_bands_init()
{
    // 3 band top Y positions (pixels) in your 1024x2592 master
    global.VIS_BAND_Y_PX = [ 0, 768, 1760 ];

    // Master tileset width (pixels)
    global.VIS_TS_W_PX = 1024;

    // Guard against uninitialized or invalid tile sizes to avoid div-by-zero at startup.
    var tile_w = (variable_global_exists("TILE_W") && is_real(global.TILE_W) && global.TILE_W > 0) ? global.TILE_W : 32;
    var tile_h = (variable_global_exists("TILE_H") && is_real(global.TILE_H) && global.TILE_H > 0) ? global.TILE_H : 32;

    // Tiles per row (1024 / 32 = 32)
    global.VIS_TILES_PER_ROW = max(1, global.VIS_TS_W_PX div tile_w);

    // Convert Y px -> tile index offsets
    global.VIS_BAND_INDEX_OFF = array_create(array_length(global.VIS_BAND_Y_PX), 0);

    for (var i = 0; i < array_length(global.VIS_BAND_Y_PX); i++)
    {
        var row_off = global.VIS_BAND_Y_PX[i] div tile_h; // 768/32=24, 1760/32=55
        global.VIS_BAND_INDEX_OFF[i] = row_off * global.VIS_TILES_PER_ROW;
    }

    // Default band (0 easy, 1 normal, 2 hard)
    if (!variable_global_exists("DIFF_VIS_BAND")) global.DIFF_VIS_BAND = 1;
}
