function scr_hitline_time_world()
{
    // Editor: chart time is the source of truth.
    if (variable_global_exists("editor_on") && global.editor_on)
    {
        return scr_chart_time();
    }

    // Boss room: use chart time (NOT camera-based world time)
    if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss"
        && variable_global_exists("BOSS_ROOM") && room == global.BOSS_ROOM)
    {
        return scr_chart_time();
    }

    var cam = view_camera[0];
    var cam_x = camera_get_view_x(cam);

    var pps = (variable_global_exists("WORLD_PPS") && is_real(global.WORLD_PPS)) ? global.WORLD_PPS : 1.0;
    if (!is_real(pps) || is_nan(pps) || pps <= 0) pps = 1.0;

    var hit_x = (variable_global_exists("HITLINE_X") && is_real(global.HITLINE_X)) ? global.HITLINE_X : 448;
    if (!is_real(hit_x) || is_nan(hit_x)) hit_x = 448;

    var hit_world_x = cam_x + hit_x;

    var off = (variable_global_exists("HITLINE_TIME_OFFSET_S") && is_real(global.HITLINE_TIME_OFFSET_S)) ? global.HITLINE_TIME_OFFSET_S : 0.0;
    if (!is_real(off) || is_nan(off)) off = 0.0;

    return (hit_world_x / pps) + off;
}
