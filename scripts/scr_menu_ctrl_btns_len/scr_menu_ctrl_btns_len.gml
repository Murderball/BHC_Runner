/// @function scr_menu_ctrl_btns_len(_ctrl)
/// @param _ctrl
/// @returns {real}
function scr_menu_ctrl_btns_len(_ctrl)
{
    if (!instance_exists(_ctrl)) return 0;
    if (!variable_instance_exists(_ctrl, "btns")) return 0;

    var b = _ctrl.btns;
    if (!is_array(b)) return 0;

    return array_length(b);
}
