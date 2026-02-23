function scr_player_lane_from_y(py)
{
    if (variable_global_exists("PLAYER_LANE_Y") && is_array(global.PLAYER_LANE_Y) && array_length(global.PLAYER_LANE_Y) >= 4)
    {
        var best = 0;
        var bestd = 1000000;

        for (var i = 0; i < array_length(global.PLAYER_LANE_Y); i++)
        {
            var d = abs(py - global.PLAYER_LANE_Y[i]);
            if (d < bestd) { bestd = d; best = i; }
        }
        return clamp(best, 0, 3);
    }

    var gh = display_get_gui_height();
    var y0 = gh * 0.62;
    var y3 = gh * 0.86;

    var t = clamp((py - y0) / max(1, (y3 - y0)), 0, 1);
    return clamp(floor(t * 4), 0, 3);
}
