function scr_time_hitline() {
    var pps = (variable_global_exists("WORLD_PPS")) ? global.WORLD_PPS : 350;
    if (pps <= 0) pps = 1;
    var _pps_denom = pps;
    if (_pps_denom == 0) {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        _pps_denom = 1;
    }
    return scr_time_camera_left() + (global.HITLINE_X / _pps_denom);
}
