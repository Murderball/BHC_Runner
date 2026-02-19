function scr_editor_find_hold_end_at(gui_x, gui_y, now_time, radius_px)
{
    var best_i = -1;
    var best_d2 = radius_px * radius_px;

    for (var i = 0; i < array_length(global.chart); i++)
    {
        var nref = global.chart[i];
        if (!is_struct(nref)) continue;
        if (nref.type != "hold") continue;

        var end_t  = nref.t + nref.dur;
        var end_gx = global.HIT_X_GUI + (end_t - now_time) * scr_timeline_pps();

        // Lane-free Y (matches note start)
        var end_gy = display_get_gui_height() * 0.5;
        if (variable_struct_exists(nref, "y_gui") && is_real(nref.y_gui)) {
            end_gy = nref.y_gui;
        } else if (variable_struct_exists(nref, "lane") && variable_global_exists("LANE_Y") && is_array(global.LANE_Y) && array_length(global.LANE_Y) > 0) {
            end_gy = global.LANE_Y[clamp(floor(nref.lane), 0, array_length(global.LANE_Y) - 1)];
        }

        var dx = end_gx - gui_x;
        var dy = end_gy - gui_y;
        var d2 = dx*dx + dy*dy;

        if (d2 <= best_d2) { best_d2 = d2; best_i = i; }
    }

    return best_i;
}
