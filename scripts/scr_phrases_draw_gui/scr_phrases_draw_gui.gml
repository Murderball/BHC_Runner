function scr_phrases_draw_gui() {
    var now_time = scr_song_time();
    var gui_w = display_get_gui_width();

    // Track label
    draw_set_color(c_black);
    draw_text(20, 95, "PHRASE: X/O/□/△");

    // Lane lines
    var lane_i = 0;
    while (lane_i < 4) {
        draw_set_color(make_color_rgb(60, 60, 60));
        draw_line_width(0, global.LANE_Y[lane_i], gui_w, global.LANE_Y[lane_i], 1);
        lane_i += 1;
    }

    // Pixels per second for phrase drawing
    var pps_val = scr_timeline_pps();

    // Draw phrase steps
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
            if (gx > -200 && gx < gui_w + 200) {
                var btn_lane = clamp(st.b - 1, 0, 3);
                var gy = global.LANE_Y[btn_lane];
                var act = global.LANE_TO_ACT[btn_lane]; // maps 0..3 to atk1/atk2/atk3/jump in your globals
				var spr = scr_note_sprite_index(act);
				var subimg = scr_anim_subimg(spr, phr_i * 1000 + step_i);
				draw_sprite(spr, subimg, gx, gy);


            }

            step_i += 1;
        }

        phr_i += 1;
    }

    // Active phrase status
    if (global.phrase_active) {
        draw_set_color(c_black);
        draw_text(20, 115,
            "Active step " + string(global.phrase_step_i + 1) +
            " | P:" + string(global.phrase_hits_perfect) +
            " G:" + string(global.phrase_hits_good) +
            " M:" + string(global.phrase_hits_miss)
        );
    }
}
