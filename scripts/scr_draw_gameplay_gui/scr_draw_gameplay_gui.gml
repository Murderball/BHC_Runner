function scr_draw_gameplay_gui()
{
    // --------------------------------------------------
    // MENU GUARD: do not draw gameplay UI in menu/loading
    // --------------------------------------------------
    if (room == rm_menu || (variable_global_exists("in_menu") && global.in_menu)) exit;
    if (room == rm_loading || (variable_global_exists("in_loading") && global.in_loading)) exit;

    // Safety: if chart isn't ready, still draw UI and exit cleanly
    var now_time = scr_chart_time();

    var gw = display_get_gui_width();
    var gh = display_get_gui_height();

    // --------------------------------------------------
    // HITLINE (thick + red + glow + BEAT PULSE)  [PLAY MODE]
    // --------------------------------------------------
    var hit_x = (variable_global_exists("HIT_X_GUI") ? global.HIT_X_GUI : 448);

    // Lane lines (visual only)
    for (var li = 0; li < 4; li++)
    {
        draw_set_color(make_color_rgb(60,60,60));
        draw_line_width(0, global.LANE_Y[li], gw, global.LANE_Y[li], 1);
    }

    // Beat-locked pulse (uses *hitline-time* so it stays phase-correct)
    var bpm = (variable_global_exists("BPM") && is_real(global.BPM) && global.BPM > 0) ? global.BPM : 140;
    var beat_s = 60.0 / bpm;

    var t_pulse = scr_hitline_time_world();
    if (!is_real(t_pulse) || is_nan(t_pulse)) t_pulse = now_time;

    // If you treat START_TIME_S as musical zero, include it (optional)
    if (variable_global_exists("START_TIME_S") && is_real(global.START_TIME_S)) t_pulse += global.START_TIME_S;

    var beat_i = floor(t_pulse / beat_s);
    var beat_phase = (t_pulse - (beat_i * beat_s)) / beat_s; // 0..1

    // Pulse window length (fraction of beat)
    var len = 0.22;
    if (variable_global_exists("HITLINE_PULSE_LEN_BEATS")) len = global.HITLINE_PULSE_LEN_BEATS;
    len = clamp(len, 0.05, 0.75);

    var pulse = 0.0;
    if (beat_phase < len)
    {
        var u = 1.0 - (beat_phase / len); // 1 -> 0
        pulse = u * u * (3.0 - 2.0 * u);  // smoothstep
    }

    // Downbeat emphasis
    var bpb = (variable_global_exists("BEATS_PER_BAR") && is_real(global.BEATS_PER_BAR) && global.BEATS_PER_BAR > 0) ? global.BEATS_PER_BAR : 4;
    var is_downbeat = ((beat_i mod bpb) == 0);

    var amp_beat = 0.55;
    var amp_down = 0.85;
    if (variable_global_exists("HITLINE_PULSE_AMP_BEAT")) amp_beat = global.HITLINE_PULSE_AMP_BEAT;
    if (variable_global_exists("HITLINE_PULSE_AMP_DOWN")) amp_down = global.HITLINE_PULSE_AMP_DOWN;

    var amp = is_downbeat ? amp_down : amp_beat;
    amp = clamp(amp, 0.0, 2.0);

    // Pulse amount (0..~2)
    var p = pulse * amp;

    // Glow geometry (pulse expands + brightens)
    var y0 = 0;
    var y1 = gh;

    var core_w  = 6 + (4 * p);
    var glow_w1 = 18 + (12 * p);
    var glow_w2 = 36 + (24 * p);
    var glow_w3 = 60 + (40 * p);

    var core_col = make_color_rgb(255, 40, 40);
    var glow_col = make_color_rgb(255, 70, 70);

    gpu_set_blendmode(bm_add);
    draw_set_color(glow_col);

    draw_set_alpha(0.06 * (1 + p));
    draw_rectangle(hit_x - glow_w3 * 0.5, y0, hit_x + glow_w3 * 0.5, y1, false);

    draw_set_alpha(0.12 * (1 + p));
    draw_rectangle(hit_x - glow_w2 * 0.5, y0, hit_x + glow_w2 * 0.5, y1, false);

    draw_set_alpha(0.20 * (1 + p));
    draw_rectangle(hit_x - glow_w1 * 0.5, y0, hit_x + glow_w1 * 0.5, y1, false);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(core_col);
    draw_rectangle(hit_x - core_w * 0.5, y0, hit_x + core_w * 0.5, y1, false);

    // --------------------------------------------------
    // Quick debug
    // --------------------------------------------------
    if (!variable_global_exists("chart") || is_undefined(global.chart)) {
        draw_set_color(c_yellow);
        draw_text(20, 60, "chart_len=<undefined>");
        draw_set_color(c_black);
        return;
    }

    var chart_len = array_length(global.chart);
    draw_set_color(c_yellow);
    draw_text(20, 60, "chart_len=" + string(chart_len) + "  pps=" + string(round(scr_timeline_pps())));
    draw_set_color(c_black);

    draw_set_color(c_yellow);
    draw_text(20, 140, "AUTO_HIT: " + string(variable_global_exists("AUTO_HIT") && global.AUTO_HIT));
    draw_set_color(c_black);

    // Notes
    for (var i = 0; i < chart_len; i++)
    {
        var nref = global.chart[i];

        // Always define these before any drawing
        var start_gx = scr_note_screen_x(nref.t, now_time);

        // Lane-free: notes store their own GUI Y (like enemies)
        var start_gy = display_get_gui_height() * 0.5;
        if (is_struct(nref) && variable_struct_exists(nref, "y_gui") && is_real(nref.y_gui)) {
            start_gy = nref.y_gui;
        } else {
            // Legacy fallback
            start_gy = global.LANE_Y[clamp(floor(nref.lane), 0, array_length(global.LANE_Y)-1)];
        }

        var was_hit = (variable_struct_exists(nref, "hit") && nref.hit);

        if (was_hit) draw_set_alpha(0.35);
        else         draw_set_alpha(1);

        // Cull far off-screen
        if (start_gx < -400) continue;
        if (start_gx > gw + 400) continue;

        // Choose sprite per action (falls back to spr_note if missing)
        var spr = spr_note_atk1;
        if (script_exists(scr_note_sprite_index)) spr = scr_note_sprite_index(nref.act);

        // Animated subimages (real-time, so they animate during pause overlay too)
        var subimg_start = 0;
        var subimg_end   = 0;
        if (script_exists(scr_anim_subimg)) {
            subimg_start = scr_anim_subimg(spr, i);
            subimg_end   = scr_anim_subimg(spr, i + 9999);
        }

        // Hold visuals
        if (nref.type == "hold")
        {
            var end_t = nref.t + nref.dur;
            var end_gx = scr_note_screen_x(end_t, now_time);

            draw_set_color(make_color_rgb(200,200,200));
            draw_line_width(start_gx, start_gy, end_gx, start_gy, 6);

            // Hold end marker
            draw_set_alpha(global.hold_end_alpha);
            if (spr != -1) draw_sprite(spr, subimg_end, end_gx, start_gy);
            else {
                draw_set_color(c_aqua);
                draw_rectangle(end_gx - 10, start_gy - 10, end_gx + 10, start_gy + 10, false);
            }
            draw_set_alpha(1);
        }

        // Start note marker
        if (spr != -1) draw_sprite(spr, subimg_start, start_gx, start_gy);
        else {
            draw_set_color(c_aqua);
            draw_rectangle(start_gx - 10, start_gy - 10, start_gx + 10, start_gx + 10, false);
            draw_set_color(c_black);
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_black);
}
