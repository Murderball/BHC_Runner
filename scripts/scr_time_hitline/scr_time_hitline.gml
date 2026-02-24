function scr_time_hitline() {
    var pps = (variable_global_exists("WORLD_PPS")) ? global.WORLD_PPS : 350;
    if (pps <= 0) pps = 1;
    var denom_pps = pps;
if (denom_pps == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_pps = 1;
}
return scr_time_camera_left() + (global.HITLINE_X / denom_pps);
}
