function scr_editor_place_enemy(_kind)
{
    if (!variable_global_exists("chart")) return;
    if (!is_array(global.chart)) return;

    // Snap time + lane
    var t_place = global.editor_time;
    t_place = scr_editor_snap_time(t_place);

    var lane_i = scr_editor_lane_from_mouse();
    lane_i = clamp(floor(lane_i), 0, 3);

    // BIGGER tolerance (float snap jitter safe)
    var eps = 0.02;

    // If one already exists at this time+lane (same kind), do nothing
    var len = array_length(global.chart);
    for (var i = 0; i < len; i++)
    {
        var n = global.chart[i];
        if (!is_struct(n)) continue;
        if (!variable_struct_exists(n, "type")) continue;
        if (n.type != "enemy") continue;
        if (!variable_struct_exists(n, "t")) continue;

        var n_lane = 0;
        if (variable_struct_exists(n, "lane")) n_lane = n.lane;

        if (abs(n.t - t_place) <= eps && n_lane == lane_i)
        {
            // If kind matches, return (already there)
            var n_kind = "";
            if (variable_struct_exists(n, "enemy_kind")) n_kind = string(n.enemy_kind);
            if (n_kind == string(_kind)) return;
        }
    }

    // Add enemy
    array_push(global.chart, {
        type: "enemy",
        t: t_place,
        lane: lane_i,
        enemy_kind: string(_kind)
    });

    // HARD DE-DUPE PASS:
    // Keep the newest one we just added, delete any other enemy at same time+lane (any kind)
    // This guarantees you never get 2 enemies stacked by accident.
    var keep_i = array_length(global.chart) - 1;

    for (var j = array_length(global.chart) - 2; j >= 0; j--)
    {
        var e = global.chart[j];
        if (!is_struct(e)) continue;
        if (!variable_struct_exists(e, "type")) continue;
        if (e.type != "enemy") continue;
        if (!variable_struct_exists(e, "t")) continue;
        if (!variable_struct_exists(e, "lane")) continue;

        if (e.lane == lane_i && abs(e.t - t_place) <= eps)
        {
            array_delete(global.chart, j, 1);
            keep_i -= 1; // array shrank before keep index
        }
    }
	show_debug_message("ENEMY PLACE: t=" + string(t_place) + " lane=" + string(lane_i) + " kind=" + string(_kind));

}
