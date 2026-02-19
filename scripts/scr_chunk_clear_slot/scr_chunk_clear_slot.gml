/// scr_chunk_clear_slot(slot)
/// Clears a single slot region in all tilemaps (E/N/H + Collide).
/// Fixes closure-scope issues by passing W/H/base into the helper.

function scr_chunk_clear_slot(slot)
{
    var W = global.CHUNK_W_TILES;
    var H = global.CHUNK_H_TILES;

    var base_tx = slot * W;

    // Tilemap ids (safe)
    var tmE = (variable_global_exists("tm_vis_easy")   ? global.tm_vis_easy   : -1);
    var tmN = (variable_global_exists("tm_vis_normal") ? global.tm_vis_normal : -1);
    var tmH = (variable_global_exists("tm_vis_hard")   ? global.tm_vis_hard   : -1);
    var tmC = (variable_global_exists("tm_collide")    ? global.tm_collide    : -1);

    // Clear helper (NO closure capture)
    function _clear_tm(_tm, _W, _H, _base_tx)
    {
        if (_tm == -1) return;

        for (var ty = 0; ty < _H; ty++)
        for (var tx = 0; tx < _W; tx++)
        {
            tilemap_set(_tm, 0, _base_tx + tx, ty);
        }
    }

    _clear_tm(tmE, W, H, base_tx);
    _clear_tm(tmN, W, H, base_tx);
    _clear_tm(tmH, W, H, base_tx);
    _clear_tm(tmC, W, H, base_tx);
}