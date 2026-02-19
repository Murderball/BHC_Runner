function scr_chunk_stamp_ci(data, ci) {
    if (global.tm_visual == -1 || global.tm_collide == -1) return;

    var cw = global.CHUNK_W_TILES;
    var ch = global.CHUNK_H_TILES;

    var base_tx = ci * cw;

    // ---------- helpers (scope-safe: no captured locals) ----------
    function _get_key(_d, _k) {
        if (is_struct(_d) && variable_struct_exists(_d, _k)) return _d[$ _k];
        return undefined;
    }

    function _pick_layer(_d, _keys) {
        for (var i = 0; i < array_length(_keys); i++) {
            var v = _get_key(_d, _keys[i]);
            if (v != undefined) return v;
        }
        return undefined;
    }

    function _get_cell(_layer, _x, _y, _cw) {
        if (_layer == undefined) return 0;

        // If it's a struct wrapper, dig deeper
        if (is_struct(_layer)) {
            var inner = _pick_layer(_layer, ["tiles","data","grid","cells","values"]);
            if (inner != undefined) _layer = inner;
        }

        if (is_array(_layer)) {

            // 2D array: layer[y][x]
            if (array_length(_layer) > 0 && is_array(_layer[0])) {
                if (_y >= 0 && _y < array_length(_layer)) {
                    var row = _layer[_y];
                    if (is_array(row) && _x >= 0 && _x < array_length(row)) {
                        var v2 = row[_x];
                        return real(v2);
                    }
                }
                return 0;
            }

            // Flat array: layer[y*cw + x]
            var idx = _y * _cw + _x;
            if (idx >= 0 && idx < array_length(_layer)) {
                var v1 = _layer[idx];
                return real(v1);
            }
            return 0;
        }

        return 0;
    }

    // ---------- find visual/collide layers in your json ----------
    var vis_layer = _pick_layer(data, ["visual","vis","tm_visual","tiles_visual","layer_visual","TL_Visual"]);
    var col_layer = _pick_layer(data, ["collide","collision","col","tm_collide","tiles_collide","layer_collide","TL_Collide"]);

    // Some exporters store both layers inside "layers"/"tilemaps"
    if (vis_layer == undefined || col_layer == undefined) {
        var layers = _pick_layer(data, ["layers","tilemaps","maps"]);
        if (layers != undefined) {

            // Array of layer objects
            if (is_array(layers)) {
                for (var i = 0; i < array_length(layers); i++) {
                    var L = layers[i];
                    if (!is_struct(L)) continue;

                    var nm = "";
                    if (variable_struct_exists(L, "name")) nm = string(L.name);

                    if (vis_layer == undefined && (nm == "TL_Visual" || nm == "visual" || nm == "vis")) vis_layer = L;
                    if (col_layer == undefined && (nm == "TL_Collide" || nm == "collide" || nm == "collision" || nm == "col")) col_layer = L;
                }
            }
            // Struct map of layers
            else if (is_struct(layers)) {
                if (vis_layer == undefined) vis_layer = _pick_layer(layers, ["visual","TL_Visual","vis"]);
                if (col_layer == undefined) col_layer = _pick_layer(layers, ["collide","TL_Collide","collision","col"]);
            }
        }
    }

    // ---------- stamp ----------
    for (var ty = 0; ty < ch; ty++) {
        for (var tx = 0; tx < cw; tx++) {
            var v = _get_cell(vis_layer, tx, ty, cw);
            var c = _get_cell(col_layer, tx, ty, cw);

            if (v == undefined) v = 0;
            if (c == undefined) c = 0;

            tilemap_set(global.tm_visual,  max(0, v), base_tx + tx, ty);
            tilemap_set(global.tm_collide, max(0, c), base_tx + tx, ty);
        }
    }
}
