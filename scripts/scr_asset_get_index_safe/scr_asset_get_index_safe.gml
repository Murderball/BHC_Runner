/// @function scr_asset_get_index_safe(_name, _fallback)
/// @param _name Asset name string.
/// @param _fallback Fallback asset index/value.
/// @returns Asset index when found, else fallback.
function scr_asset_get_index_safe(_name, _fallback)
{
    if (is_string(_name)) {
        var idx = asset_get_index(_name);
        if (idx != -1) return idx;
    }
    return _fallback;
}
