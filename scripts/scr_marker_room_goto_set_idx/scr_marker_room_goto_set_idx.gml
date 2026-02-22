/// @function scr_marker_room_goto_set_idx(marker_ref, new_idx)
/// @param marker_ref Marker struct (passed by ref)
/// @param new_idx Requested destination index
function scr_marker_room_goto_set_idx(marker_ref, new_idx)
{
    if (!is_struct(marker_ref)) return;

    var _count = variable_global_exists("SIDE_ROOM_COUNT") ? max(1, floor(real(global.SIDE_ROOM_COUNT))) : 1;
    var _idx = floor(real(new_idx));
    _idx = ((_idx mod _count) + _count) mod _count;

    marker_ref.side_idx = _idx;
    marker_ref.kind = "room_goto";
    marker_ref.type = "room_goto";
    if (!variable_struct_exists(marker_ref, "one_shot")) marker_ref.one_shot = true;
    if (!variable_struct_exists(marker_ref, "consumed")) marker_ref.consumed = false;

    var _room_name = script_exists(scr_side_room_name_from_index)
        ? scr_side_room_name_from_index(_idx)
        : ("rm_side_" + string(_idx));

    marker_ref.caption = "GOTO " + _room_name;
}
