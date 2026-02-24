/// scr_enemy_window_times(t_anchor, margin_px)
/// Returns [t_enter, t_exit] in CHART TIME where the enemy is considered "visible"

function scr_enemy_window_times(_t_anchor, _margin_px)
{
    var gw  = display_get_gui_width();
    var pps = scr_timeline_pps();
    if (pps <= 0) pps = 1;

    // When x == gw+margin (enter from right)
    var denom_pps_enter = pps;
if (denom_pps_enter == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_pps_enter = 1;
}
var t_enter = _t_anchor - ((gw + _margin_px - global.HIT_X_GUI) / denom_pps_enter);

    // When x == -margin (exit left)
    var denom_pps_exit = pps;
if (denom_pps_exit == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_pps_exit = 1;
}
var t_exit  = _t_anchor + ((global.HIT_X_GUI + _margin_px) / denom_pps_exit);

    return [t_enter, t_exit];
}
