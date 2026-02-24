/// scr_lane_pressed(lane)
function scr_lane_pressed(_lane)
{
    if (variable_global_exists("AUTO_HIT_ENABLED") && global.AUTO_HIT_ENABLED) return true;
    return keyboard_check_pressed(global.LANE_KEY[_lane]);
}
