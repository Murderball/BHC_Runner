function scr_editor_phrase_pick(gui_x, gui_y) {
    var now_time = scr_chart_time
    var pps_val = scr_timeline_pps();

    var best_phrase = -1;
    var best_step = 0;

    var radius = 22;
    var best_d2 = radius * radius;

    var phrase_count = array_length(global.phrases);
    var phr_i = 0;

    while (phr_i < phrase_count) {
        var ph = global.phrases[phr_i];
        var step_count = array_length(ph.steps);

        var step_i = 0;
        while (step_i < step_count) {
            var st = ph.steps[step_i];
            var step_time = ph.t + st.dt;

            var gx = global.HIT_X_GUI + (step_time - now_time) * pps_val;
            var btn_lane = clamp(st.b - 1, 0, 3);
            var gy = global.LANE_Y[btn_lane];

            var dx = gx - gui_x;
            var dy = gy - gui_y;
            var d2 = dx*dx + dy*dy;

            if (d2 <= best_d2) {
                best_d2 = d2;
                best_phrase = phr_i;
                best_step = step_i;
            }

            step_i += 1;
        }

        phr_i += 1;
    }

    global.editor_phrase_step_sel = best_step;
    return best_phrase;
}
