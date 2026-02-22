/// @function scr_sprite_exists_by_name(_name)
/// @param _name Sprite asset name string
/// @returns {bool} True if a sprite asset with that name exists.
function scr_sprite_exists_by_name(_name)
{
    if (!is_string(_name)) return false;
    var idx = asset_get_index(_name);
    if (idx == -1) return false;
    return asset_get_type(idx) == asset_sprite;
}
