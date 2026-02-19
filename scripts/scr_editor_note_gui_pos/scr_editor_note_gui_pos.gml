function scr_editor_note_gui_pos(note_struct, now_time)
{
    // X is timeline-based
    var gx = scr_note_screen_x(note_struct.t, now_time);

    // Y is lane-free (stored per-note), like enemies.
    // Fallback to legacy lane positioning if y_gui isn't present.
    var gy = display_get_gui_height() * 0.5;

    if (is_struct(note_struct))
    {
        if (variable_struct_exists(note_struct, "y_gui") && is_real(note_struct.y_gui))
        {
            gy = note_struct.y_gui;
        }
        else if (variable_struct_exists(note_struct, "lane") && variable_global_exists("LANE_Y") && is_array(global.LANE_Y) && array_length(global.LANE_Y) > 0)
        {
            var li = clamp(floor(note_struct.lane), 0, array_length(global.LANE_Y) - 1);
            gy = global.LANE_Y[li];
        }
    }

    return { gx: gx, gy: gy };
}
