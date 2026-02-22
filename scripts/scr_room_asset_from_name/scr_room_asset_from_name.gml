/// @function scr_room_asset_from_name(room_name)
/// @param room_name Room asset name string
/// @returns Asset index or -1 when missing
function scr_room_asset_from_name(room_name)
{
    if (!is_string(room_name) || string_length(room_name) <= 0) return -1;

    var _asset = asset_get_index(room_name);
    if (_asset < 0) return -1;

    return _asset;
}
