function scr_time_hitline() {
    var pps = (variable_global_exists("WORLD_PPS")) ? global.WORLD_PPS : 350;
    if (pps <= 0) pps = 1;
    return scr_time_camera_left() + (global.HITLINE_X / pps);
}
