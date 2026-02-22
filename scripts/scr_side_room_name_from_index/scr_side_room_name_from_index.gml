/// @function scr_side_room_name_from_index(idx)
/// @param idx Integer side-room index (wrapped to 0..SIDE_ROOM_COUNT-1)
/// @returns String room asset name (ex: rm_side_00)
function scr_side_room_name_from_index(idx)
{
    var _count = variable_global_exists("SIDE_ROOM_COUNT") ? max(1, floor(real(global.SIDE_ROOM_COUNT))) : 1;
    var _digits = variable_global_exists("SIDE_ROOM_DIGITS") ? max(1, floor(real(global.SIDE_ROOM_DIGITS))) : 2;
    var _prefix = variable_global_exists("SIDE_ROOM_PREFIX") ? string(global.SIDE_ROOM_PREFIX) : "rm_side_";

    var _idx = floor(real(idx));
    _idx = ((_idx mod _count) + _count) mod _count;

    var _num = string(_idx);
    while (string_length(_num) < _digits)
    {
        _num = "0" + _num;
    }

    return _prefix + _num;
}
