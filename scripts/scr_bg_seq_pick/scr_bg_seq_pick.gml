/// scr_bg_seq_pick(bg_map, section_name, p01)
/// Returns a sprite id, chosen from either:
/// - a single sprite
/// - an array of sprites (sequence), indexed by p01

function scr_bg_seq_pick(_bg_map, _name, _p01)
{
    if (is_undefined(_bg_map) || !ds_exists(_bg_map, ds_type_map)) return -1;

    var key = string_lower(string(_name));
    if (!ds_map_exists(_bg_map, key)) return -1;

    var v = _bg_map[? key];

    // single sprite
    if (!is_array(v)) return v;

    // sequence
    var n = array_length(v);
    if (n <= 0) return -1;

    var p = clamp(_p01, 0, 0.999999);
    var idx = clamp(floor(p * n), 0, n - 1);
    return v[idx];
}