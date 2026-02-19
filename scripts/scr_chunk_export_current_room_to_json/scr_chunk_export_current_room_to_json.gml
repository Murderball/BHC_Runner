/// scr_chunk_export_current_room_to_json()
/// Exports current room chunk to chunk_<roomname>.json
/// Reads ONLY:
///   - TL_Collide
///   - TL_Visual_Easy / TL_Visual_Normal / TL_Visual_Hard
/// Ignores TL_Preview_Visual_* (preview layers are for viewing stamps only)
///
/// Payload: w,h,col,vis_easy,vis_normal,vis_hard
function scr_chunk_export_current_room_to_json()
{
    scr_chunk_system_init();

    var W = global.CHUNK_W_TILES;
    var H = global.CHUNK_H_TILES;

    // --- helpers ---
    function _get_tm(_layer_name)
    {
        var lid = layer_get_id(_layer_name);
        if (lid == -1) return -1;
        return layer_tilemap_get_id(lid);
    }

    function _is_empty_tile(_td)
    {
        // Empty in serialized YY is often -2147483648; runtime can sometimes be 0
        return (_td == 0) || (_td == -2147483648);
    }

    function _read_tm(_tm_id, _W, _H)
    {
        var arr = array_create(_W * _H, 0);
        if (_tm_id == -1) return arr;

        for (var ty = 0; ty < _H; ty++)
        for (var tx = 0; tx < _W; tx++)
        {
            var i = tx + ty * _W;
            arr[i] = tilemap_get(_tm_id, tx, ty);
        }
        return arr;
    }

    function _count_nonempty(_arr)
    {
        var n = 0;
        for (var i = 0; i < array_length(_arr); i++)
        {
            if (!_is_empty_tile(_arr[i])) n++;
        }
        return n;
    }

    // --- collide (required) ---
    var tm_col = _get_tm("TL_Collide");
    if (tm_col == -1)
    {
        show_debug_message("[Export] ERROR: missing TL_Collide tile layer in " + room_get_name(room));
        return false;
    }

    // --- visuals (AUTHORED layers ONLY) ---
    var tm_vis_easy  = _get_tm("TL_Visual_Easy");
    var tm_vis_norm  = _get_tm("TL_Visual_Normal");
    var tm_vis_hard  = _get_tm("TL_Visual_Hard");

    var col_arr  = _read_tm(tm_col, W, H);
    var easy_arr = _read_tm(tm_vis_easy, W, H);
    var norm_arr = _read_tm(tm_vis_norm, W, H);
    var hard_arr = _read_tm(tm_vis_hard, W, H);

    // --- optional warning: you might have painted on preview layer instead ---
    // (Does NOT export preview. Only detects and warns.)
    var tm_prev_hard = _get_tm("TL_Preview_Visual_Hard");
    if (tm_prev_hard != -1)
    {
        var prev_hard_arr = _read_tm(tm_prev_hard, W, H);

        var hard_count = _count_nonempty(hard_arr);
        var prev_count = _count_nonempty(prev_hard_arr);

        if (hard_count == 0 && prev_count > 0)
        {
            show_debug_message(
                "[Export] WARNING: TL_Visual_Hard is empty but TL_Preview_Visual_Hard has tiles.\n" +
                "You likely stamped/painted on the PREVIEW layer. Export ignores preview layers by design.\n" +
                "Move/copy tiles to TL_Visual_Hard (authored layer) and re-export."
            );
        }
    }

    // --- payload ---
    var payload = {
        w: W,
        h: H,
        col: col_arr,
        vis_easy: easy_arr,
        vis_normal: norm_arr,
        vis_hard: hard_arr
    };

    var json_txt = json_stringify(payload);

    var rn = room_get_name(room);
    var fname = scr_chunks_dir() + "chunk_" + rn + ".json";

    var f = file_text_open_write(fname);
    file_text_write_string(f, json_txt);
    file_text_close(f);

    show_debug_message("[Export] Wrote: " + fname);
    return true;
}
