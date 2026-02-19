/// scr_visual_bands_init()
/// Builds tile index offsets for the 3 vertical bands in the master tileset sprite.
function scr_visual_bands_init()
{
    // 3 band top Y positions (pixels) in your 1024x2592 master
    global.VIS_BAND_Y_PX = [ 0, 768, 1760 ];

    // Master tileset width (pixels)
    global.VIS_TS_W_PX = 1024;

    // Tiles per row (1024 / 32 = 32)
    global.VIS_TILES_PER_ROW = global.VIS_TS_W_PX div global.TILE_W;

    // Convert Y px -> tile index offsets
    global.VIS_BAND_INDEX_OFF = array_create(array_length(global.VIS_BAND_Y_PX), 0);

    for (var i = 0; i < array_length(global.VIS_BAND_Y_PX); i++)
    {
        var row_off = global.VIS_BAND_Y_PX[i] div global.TILE_H; // 768/32=24, 1760/32=55
        global.VIS_BAND_INDEX_OFF[i] = row_off * global.VIS_TILES_PER_ROW;
    }

    // Default band (0 easy, 1 normal, 2 hard)
    if (!variable_global_exists("DIFF_VIS_BAND")) global.DIFF_VIS_BAND = 1;
}