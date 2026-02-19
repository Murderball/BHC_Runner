/// scr_bg_sprite_for_section(bg_map, section_name, progress01)
/// Returns a sprite index.
/// - If bg_map[section_name] is a sprite => returns it
/// - If it's an array => picks based on progress 0..1

function scr_bg_sprite_for_section(_bg_map, _section_name, _p01)
{
    if (is_undefined(_bg_map) || !ds_exists(_bg_map, ds_type_map)) return -1;

    var key = string_lower(string(_section_name));
    if (!ds_map_exists(_bg_map, key)) return -1;

    var v = _bg_map[? key];

    // Clamp progress
    var p = clamp(_p01, 0, 0.999999);

    // If it's an array, pick index by progress
    if (is_array(v))
    {
        var n = array_length(v);
        if (n <= 0) return -1;

        var idx = clamp(floor(p * n), 0, n - 1);
        return v[idx];
    }

    // Otherwise assume it’s a sprite id
    return v;
}