/// scr_enemy_window_times(t_anchor, margin_px)
/// Returns [t_enter, t_exit] in CHART TIME where the enemy is considered "visible"

function scr_enemy_window_times(_t_anchor, _margin_px)
{
    var gw  = display_get_gui_width();
    var pps = scr_timeline_pps();
    if (pps <= 0) pps = 1;

    // When x == gw+margin (enter from right)
    var t_enter = _t_anchor - ((gw + _margin_px - global.HIT_X_GUI) / pps);

    // When x == -margin (exit left)
    var t_exit  = _t_anchor + ((global.HIT_X_GUI + _margin_px) / pps);

    return [t_enter, t_exit];
}
