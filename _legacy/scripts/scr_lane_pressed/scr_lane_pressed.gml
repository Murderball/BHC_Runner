/// scr_lane_pressed(lane)
function scr_lane_pressed(_lane)
{
    if (global.AUTO_HIT) return true;
    return keyboard_check_pressed(global.LANE_KEY[_lane]);
}
