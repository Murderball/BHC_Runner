/// scr_lane_pressed(lane)
function scr_lane_pressed(_lane)
{
    if (scr_autohit_enabled()) return true;
    return keyboard_check_pressed(global.LANE_KEY[_lane]);
}
