function scr_calibrate_hitline_time_zero() {
    var cam = view_camera[0];
    var cam_x = camera_get_view_x(cam);

    // Safe WORLD_PPS fallback
    var pps = 448;
    if (variable_global_exists("WORLD_PPS")) {
        pps = global.WORLD_PPS;
    }
    if (pps <= 0) pps = 1;

    // Hitline is  from left
    var hit_world_x = cam_x + 448;

    // Force hitline-time to be 0 right now
    var denom_pps = pps;
if (denom_pps == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_pps = 1;
}
global.HITLINE_TIME_OFFSET_S = -(hit_world_x / denom_pps);
}
