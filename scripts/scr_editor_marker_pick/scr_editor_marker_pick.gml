/// scr_editor_marker_pick(gui_x, gui_y)
/// Returns marker index if mouse is near a marker line, else -1.

function scr_editor_marker_pick(gui_x, gui_y)
{
    var now_time = scr_chart_time();
    var pps_val  = scr_timeline_pps();
    var gui_h    = display_get_gui_height();

    // Only pick if inside the main timeline/lanes area
    if (gui_y < 40 || gui_y > gui_h - 140) return -1;

    if (!is_array(global.markers) || array_length(global.markers) == 0) return -1;

    var best    = -1;
    var best_dx = 999999;

    for (var i = 0; i < array_length(global.markers); i++)
    {
        var m = global.markers[i];
        if (!is_struct(m)) continue;
        if (!variable_struct_exists(m, "t")) continue;

        var gx = global.HIT_X_GUI + (m.t - now_time) * pps_val;

        var dx = abs(gx - gui_x);
        if (dx <= 10 && dx < best_dx)
        {
            best_dx = dx;
            best    = i;
        }
    }

    return best;
}