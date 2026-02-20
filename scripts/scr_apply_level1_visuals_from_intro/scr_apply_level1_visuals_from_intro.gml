function scr_apply_level1_visuals_from_intro()
{
    var SOURCE_ROOM_NAME = "rm1_chunk_intro_00";
    var TARGET_PREFIX = "rm1_chunk_";

    function _layer_find_by_name(_layers, _name) {
        var _count = array_length(_layers);
        for (var _i = 0; _i < _count; _i++) {
            if (variable_struct_exists(_layers[_i], "name") && _layers[_i].name == _name) {
                return _i;
            }
        }
        return -1;
    }

    function _layer_get_serialise_width(_layer, _fallback) {
        if (variable_struct_exists(_layer, "tiles_serialise_width")) return _layer.tiles_serialise_width;
        if (variable_struct_exists(_layer, "tileset_serialise_width")) return _layer.tileset_serialise_width;
        if (variable_struct_exists(_layer, "serialise_width")) return _layer.serialise_width;
        return _fallback;
    }

    function _layer_get_serialise_height(_layer, _fallback) {
        if (variable_struct_exists(_layer, "tiles_serialise_height")) return _layer.tiles_serialise_height;
        if (variable_struct_exists(_layer, "tileset_serialise_height")) return _layer.tileset_serialise_height;
        if (variable_struct_exists(_layer, "serialise_height")) return _layer.serialise_height;
        return _fallback;
    }

    function _copy_tiles_to_size(_src_tiles, _src_w, _src_h, _dst_w, _dst_h) {
        var _out = array_create(_dst_w * _dst_h, -2147483648);

        var _copy_w = min(_src_w, _dst_w);
        var _copy_h = min(_src_h, _dst_h);

        for (var _y = 0; _y < _copy_h; _y++) {
            for (var _x = 0; _x < _copy_w; _x++) {
                var _si = _x + _y * _src_w;
                var _di = _x + _y * _dst_w;
                _out[_di] = _src_tiles[_si];
            }
        }

        return _out;
    }

    function _make_tile_layer(_name, _depth, _tileset_index, _tiles, _w, _h) {
        var _layer = {
            type: layertype_tiles,
            name: _name,
            x: 0,
            y: 0,
            depth: _depth,
            hspeed: 0,
            vspeed: 0,
            htiled: false,
            vtiled: false,
            visible: true,
            effectEnabled: true,
            effectType: -1,
            properties: [],
            tileset_index: _tileset_index,
            tiles_serialise_width: _w,
            tiles_serialise_height: _h,
            tiles: _tiles
        };

        return _layer;
    }

    function _capture_source_layer(_room_info, _layer_name) {
        var _index = _layer_find_by_name(_room_info.layers, _layer_name);
        if (_index == -1) return undefined;

        var _layer = _room_info.layers[_index];
        if (!variable_struct_exists(_layer, "tiles")) return undefined;

        var _sw = _layer_get_serialise_width(_layer, 0);
        var _sh = _layer_get_serialise_height(_layer, 0);

        var _tiles_copy = array_create(array_length(_layer.tiles), 0);
        array_copy(_tiles_copy, 0, _layer.tiles, 0, array_length(_layer.tiles));

        return {
            name: _layer_name,
            depth: variable_struct_exists(_layer, "depth") ? _layer.depth : 0,
            tileset_index: _layer.tileset_index,
            width: _sw,
            height: _sh,
            tiles: _tiles_copy
        };
    }

    var _source_room = asset_get_index(SOURCE_ROOM_NAME);
    if (_source_room == -1) {
        show_debug_message("Source room not found: " + SOURCE_ROOM_NAME);
        return;
    }

    var _source_info = room_get_info(_source_room, false, false, true, false, true);
    if (!variable_struct_exists(_source_info, "layers")) {
        show_debug_message("Source room has no layer info: " + SOURCE_ROOM_NAME);
        return;
    }

    var _src_easy = _capture_source_layer(_source_info, "TL_Visual_Easy");
    var _src_normal = _capture_source_layer(_source_info, "TL_Visual_Normal");

    if (is_undefined(_src_easy) || is_undefined(_src_normal)) {
        show_debug_message("Source room is missing TL_Visual_Easy or TL_Visual_Normal tile data");
        return;
    }

    var _room_ids = asset_get_ids(asset_room);
    var _room_count = array_length(_room_ids);

    for (var _ri = 0; _ri < _room_count; _ri++) {
        var _room_id = _room_ids[_ri];
        var _room_name = room_get_name(_room_id);

        if (string_pos(TARGET_PREFIX, _room_name) != 1) continue;
        if (_room_name == SOURCE_ROOM_NAME) continue;

        var _info = room_get_info(_room_id, false, false, true, false, true);
        if (!variable_struct_exists(_info, "layers")) continue;

        var _room_w = variable_struct_exists(_info, "room_width") ? _info.room_width : 768;
        var _room_h = variable_struct_exists(_info, "room_height") ? _info.room_height : 1088;
        var _default_tile_w = max(1, _room_w div 32);
        var _default_tile_h = max(1, _room_h div 32);

        var _pairs = [_src_easy, _src_normal];

        for (var _pi = 0; _pi < array_length(_pairs); _pi++) {
            var _src = _pairs[_pi];
            var _layer_index = _layer_find_by_name(_info.layers, _src.name);

            if (_layer_index == -1) {
                var _new_w = (_src.width > 0) ? _src.width : _default_tile_w;
                var _new_h = (_src.height > 0) ? _src.height : _default_tile_h;
                var _new_tiles = _copy_tiles_to_size(_src.tiles, _src.width, _src.height, _new_w, _new_h);

                var _new_layer = _make_tile_layer(_src.name, _src.depth, _src.tileset_index, _new_tiles, _new_w, _new_h);
                array_push(_info.layers, _new_layer);
                continue;
            }

            var _dst_layer = _info.layers[_layer_index];
            var _dst_w = _layer_get_serialise_width(_dst_layer, _default_tile_w);
            var _dst_h = _layer_get_serialise_height(_dst_layer, _default_tile_h);

            _dst_layer.tileset_index = _src.tileset_index;
            _dst_layer.tiles = _copy_tiles_to_size(_src.tiles, _src.width, _src.height, _dst_w, _dst_h);
            _dst_layer.tiles_serialise_width = _dst_w;
            _dst_layer.tiles_serialise_height = _dst_h;

            _info.layers[_layer_index] = _dst_layer;
        }

        room_set_info(_room_id, _info);
        show_debug_message("Applied visuals to: " + _room_name);
    }
}
