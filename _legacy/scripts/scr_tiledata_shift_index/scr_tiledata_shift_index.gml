/// scr_tiledata_shift_index(td, add_index)
/// Shifts ONLY the tile index portion of tiledata, preserving flips/rotations.
/// td=0 means empty tile.
function scr_tiledata_shift_index(td, add_index)
{
    if (td == 0) return 0;

    var idx = tile_get_index(td);
    if (idx < 0) return td; // safety

    return tile_set_index(td, idx + add_index);
}