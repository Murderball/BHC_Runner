function scr_apply_level1_visuals_from_intro()
{
    function _read_text(_path)
    {
        if (!file_exists(_path)) return "";

        var _f = file_text_open_read(_path);
        var _t = "";

        while (!file_text_eof(_f)) {
            _t += file_text_read_string(_f);
            if (!file_text_eof(_f)) _t += "\n";
            file_text_readln(_f);
        }

        file_text_close(_f);
        return _t;
    }

    function _write_text(_path, _text)
    {
        var _f = file_text_open_write(_path);
        file_text_write_string(_f, _text);
        file_text_close(_f);
    }

    function _layer_block_get(_room_text, _layer_name)
    {
        var _needle = '"%Name":"' + _layer_name + '"';
        var _at = string_pos(_needle, _room_text);
        if (_at <= 0) return "";

        var _start = _at;
        while (_start > 1 && string_char_at(_room_text, _start) != "{") _start -= 1;
        if (string_char_at(_room_text, _start) != "{") return "";

        var _depth = 0;
        var _in_str = false;
        var _esc = false;
        var _len = string_length(_room_text);
        var _i = _start;

        while (_i <= _len)
        {
            var _ch = string_char_at(_room_text, _i);

            if (_in_str)
            {
                if (_esc) _esc = false;
                else if (_ch == "\\") _esc = true;
                else if (_ch == '"') _in_str = false;
            }
            else
            {
                if (_ch == '"') _in_str = true;
                else if (_ch == "{") _depth += 1;
                else if (_ch == "}")
                {
                    _depth -= 1;
                    if (_depth == 0)
                    {
                        return string_copy(_room_text, _start, _i - _start + 1);
                    }
                }
            }

            _i += 1;
        }

        return "";
    }

    function _segment_between(_text, _from, _to)
    {
        var _p1 = string_pos(_from, _text);
        if (_p1 <= 0) return "";
        _p1 += string_length(_from);

        var _tail = string_copy(_text, _p1, string_length(_text) - _p1 + 1);
        var _p2rel = string_pos(_to, _tail);
        if (_p2rel <= 0) return "";

        return string_copy(_tail, 1, _p2rel - 1);
    }

    function _replace_segment(_text, _from, _to, _new_mid)
    {
        var _p1 = string_pos(_from, _text);
        if (_p1 <= 0) return _text;

        var _mid_start = _p1 + string_length(_from);
        var _tail = string_copy(_text, _mid_start, string_length(_text) - _mid_start + 1);
        var _p2rel = string_pos(_to, _tail);
        if (_p2rel <= 0) return _text;

        var _mid_end = _mid_start + _p2rel - 2;
        var _left = string_copy(_text, 1, _mid_start - 1);
        var _right = string_copy(_text, _mid_end + 1, string_length(_text) - _mid_end);

        return _left + _new_mid + _right;
    }

    function _apply_layer_data(_target_text, _layer_name, _src_tile_data, _src_tileset_obj, _src_layer_block)
    {
        var _layer_block = _layer_block_get(_target_text, _layer_name);

        if (_layer_block != "")
        {
            var _updated = _layer_block;
            _updated = _replace_segment(_updated, '"TileCompressedData":[', '],"TileDataFormat"', _src_tile_data);
            _updated = _replace_segment(_updated, '"tilesetId":{', '},"userdefinedDepth"', _src_tileset_obj);

            return string_replace(_target_text, _layer_block, _updated);
        }

        var _collide_at = string_pos('"%Name":"TL_Collide"', _target_text);
        if (_collide_at <= 0) return _target_text;

        var _ins = _collide_at;
        while (_ins > 1 && string_char_at(_target_text, _ins) != "{") _ins -= 1;
        if (string_char_at(_target_text, _ins) != "{") return _target_text;

        var _left = string_copy(_target_text, 1, _ins - 1);
        var _right = string_copy(_target_text, _ins, string_length(_target_text) - _ins + 1);

        return _left + _src_layer_block + ",\n    " + _right;
    }

    var _src_name = "rm1_chunk_intro_00";
    var _src_path = "rooms/" + _src_name + "/" + _src_name + ".yy";
    var _src_text = _read_text(_src_path);

    if (_src_text == "") {
        show_debug_message("[apply_visuals] Source room file missing: " + _src_path);
        return;
    }

    var _src_easy_block = _layer_block_get(_src_text, "TL_Visual_Easy");
    var _src_norm_block = _layer_block_get(_src_text, "TL_Visual_Normal");

    if (_src_easy_block == "" || _src_norm_block == "") {
        show_debug_message("[apply_visuals] Source room missing TL_Visual_Easy or TL_Visual_Normal");
        return;
    }

    var _src_easy_tiles = _segment_between(_src_easy_block, '"TileCompressedData":[', '],"TileDataFormat"');
    var _src_norm_tiles = _segment_between(_src_norm_block, '"TileCompressedData":[', '],"TileDataFormat"');
    var _src_easy_tileset = _segment_between(_src_easy_block, '"tilesetId":{', '},"userdefinedDepth"');
    var _src_norm_tileset = _segment_between(_src_norm_block, '"tilesetId":{', '},"userdefinedDepth"');

    var _rid = room_first;
    while (_rid != -1)
    {
        var _rname = room_get_name(_rid);

        if (string_copy(_rname, 1, 10) == "rm1_chunk_" && _rname != _src_name)
        {
            var _path = "rooms/" + _rname + "/" + _rname + ".yy";
            var _txt = _read_text(_path);

            if (_txt != "")
            {
                var _out = _txt;
                _out = _apply_layer_data(_out, "TL_Visual_Easy", _src_easy_tiles, _src_easy_tileset, _src_easy_block);
                _out = _apply_layer_data(_out, "TL_Visual_Normal", _src_norm_tiles, _src_norm_tileset, _src_norm_block);

                if (_out != _txt) {
                    _write_text(_path, _out);
                    show_debug_message("Applied visuals to: " + _rname);
                }
            }
        }

        _rid = room_next(_rid);
    }
}
