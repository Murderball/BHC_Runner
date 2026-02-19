/// scr_pickup_spawns_from_markers()
/// Returns an array of {t,kind,y_gui,spawned:false} sorted by t
/// Lane-free: uses per-marker y_gui; generates if missing (safe fallback).
function scr_pickup_spawns_from_markers()
{
    var out = [];
    if (!variable_global_exists("markers") || !is_array(global.markers)) return out;

    var top = 140;
    var bot = display_get_gui_height() - 140;

    var pick_i = 0;

    for (var i = 0; i < array_length(global.markers); i++)
    {
        var m = global.markers[i];
        if (!is_struct(m)) continue;

        if (!variable_struct_exists(m, "type") || string(m.type) != "pickup") continue;
        if (!variable_struct_exists(m, "t") || !is_real(m.t)) continue;

        var kind = "shard";
        if (variable_struct_exists(m, "pickup_kind")) kind = string_lower(string(m.pickup_kind));

        var yg;
        if (variable_struct_exists(m, "y_gui") && is_real(m.y_gui))
            yg = m.y_gui;
        else
            yg = irandom_range(top, bot);

        yg = clamp(yg, top, bot);

        array_push(out, { t: m.t, kind: kind, y_gui: yg, spawned: false });
        pick_i++;
    }

    // Sort by time
    var n = array_length(out);
    for (var a = 0; a < n - 1; a++)
    for (var b = a + 1; b < n; b++)
    {
        if (out[a].t > out[b].t) {
            var tmp = out[a];
            out[a] = out[b];
            out[b] = tmp;
        }
    }

    return out;
}
