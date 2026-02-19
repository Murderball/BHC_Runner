function scr_editor_find_note_at(gui_x, gui_y, now_time, radius_px) {
    var best_i = -1;
    var best_d2 = radius_px * radius_px;

    for (var i = 0; i < array_length(global.chart); i++) {
        var note_ref = global.chart[i];

        var p = scr_editor_note_gui_pos(note_ref, now_time);
        var dx = p.gx - gui_x;
        var dy = p.gy - gui_y;
        var d2 = dx*dx + dy*dy;

        if (d2 <= best_d2) {
            best_d2 = d2;
            best_i = i;
        }
    }

    return best_i;
}
