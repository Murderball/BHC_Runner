/// obj_enemy_manager : Create

enemy_margin_px = 96;

enemy_spawns = [];
next_spawn_i = 0;

// 1) PRIMARY: spawn from editor markers of type "spawn"
enemy_spawns = scr_enemy_spawns_from_markers();

// 2) FALLBACK: if no spawn markers, use chart entries type == "enemy"
if (array_length(enemy_spawns) == 0)
{
    if (variable_global_exists("chart") && is_array(global.chart))
    {
        var len = array_length(global.chart);
        for (var i = 0; i < len; i++)
        {
            var n = global.chart[i];
            if (!is_struct(n)) continue;
            if (!variable_struct_exists(n, "type") || n.type != "enemy") continue;
            if (!variable_struct_exists(n, "t")) continue;

            var lane = 0;
            if (variable_struct_exists(n, "lane")) lane = clamp(floor(n.lane), 0, global.LANE_COUNT - 1);

            var kind = "poptarts";
            if (variable_struct_exists(n, "enemy_kind")) kind = string(n.enemy_kind);

            array_push(enemy_spawns, {
                t: n.t,
                lane: lane,
                kind: kind,
                y_gui: global.LANE_Y[lane],
                spawned: false
            });
        }
    }
}

