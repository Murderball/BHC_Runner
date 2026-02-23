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

    if (!variable_global_exists("dbg_song_overlay_on")) global.dbg_song_overlay_on = false;
    if (keyboard_check_pressed(vk_f10)) global.dbg_song_overlay_on = !global.dbg_song_overlay_on;


	// --------------------------------------------------
	// Song timeline track (RED bar) + vertical playhead (WHITE, beat-pulsed)
	// --------------------------------------------------
	if (!variable_global_exists("PROGRESS_LINE_ENABLED")) global.PROGRESS_LINE_ENABLED = true;

	if (global.PROGRESS_LINE_ENABLED)
	{
	    // Progress fraction 0..1 (uses your existing scr_song_progress_frac)
	    var progress_frac = scr_song_progress_frac();

	    // BPM used for beat pulse
	    var bpm_prog = (variable_global_exists("chart_bpm") && is_real(global.chart_bpm) && global.chart_bpm > 0)
	        ? global.chart_bpm
	        : ((variable_global_exists("BPM") && is_real(global.BPM) && global.BPM > 0) ? global.BPM : 140);

	    // Knobs
	    if (!variable_global_exists("PROGRESS_PULSE_STRENGTH")) global.PROGRESS_PULSE_STRENGTH = 0.45;
	    if (!variable_global_exists("PROGRESS_LINE_MARGIN"))    global.PROGRESS_LINE_MARGIN = 8;
	    if (!variable_global_exists("PROGRESS_LINE_THICKNESS")) global.PROGRESS_LINE_THICKNESS = 2;

	    // NEW knobs for the red track
	    if (!variable_global_exists("PROGRESS_TRACK_H"))        global.PROGRESS_TRACK_H = 10; // red bar height
	    if (!variable_global_exists("PROGRESS_TRACK_ALPHA"))    global.PROGRESS_TRACK_ALPHA = 1.0;

	    var pulse_strength = (is_real(global.PROGRESS_PULSE_STRENGTH)) ? global.PROGRESS_PULSE_STRENGTH : 0.45;

	    // Pulse alpha (use helper if present; otherwise no pulse)
	    var alpha_prog = 1.0;
	    if (asset_get_index("scr_beat_pulse_alpha") != -1) {
	        alpha_prog = scr_beat_pulse_alpha(bpm_prog, now_time, pulse_strength);
	    }

	    // Layout
	    var margin   = (is_real(global.PROGRESS_LINE_MARGIN)) ? floor(global.PROGRESS_LINE_MARGIN) : 8;
	    var thick    = (is_real(global.PROGRESS_LINE_THICKNESS)) ? max(1, floor(global.PROGRESS_LINE_THICKNESS)) : 2;

	    var track_h  = (is_real(global.PROGRESS_TRACK_H)) ? max(2, floor(global.PROGRESS_TRACK_H)) : 10;
	    var track_a  = (is_real(global.PROGRESS_TRACK_ALPHA)) ? clamp(global.PROGRESS_TRACK_ALPHA, 0.0, 1.0) : 1.0;

	    var x_left   = margin;
	    var x_right  = gw - margin;

	    // Position at very top; bar is centered on y_top
	    var y_top    = margin;
	    var y0       = y_top - track_h * 0.5;
	    var y1       = y_top + track_h * 0.5;

	    // Compute playhead x
	    progress_frac = clamp(progress_frac, 0.0, 1.0);
	    var x_head = lerp(x_left, x_right, progress_frac);

	    // --- Draw RED track bar (full level play time) ---
	    draw_set_alpha(track_a);
	    draw_set_color(c_red);
	    draw_rectangle(x_left, y0, x_right, y1, false);

	    // Optional: crisp white top baseline edge
	    draw_set_alpha(1);
	    draw_set_color(c_white);
	    draw_line_width(x_left, y_top, x_right, y_top, 1);

	    // --- Draw WHITE playhead (vertical line) with beat pulse ---
	    var head_h = track_h + 10; // slightly taller than track
	    draw_set_alpha(alpha_prog);
	    draw_set_color(c_white);
	    draw_line_width(x_head, y_top - (head_h * 0.5), x_head, y_top + (head_h * 0.5), thick);

	    draw_set_alpha(1);
	}

    // --------------------------------------------------
    // Divisional lines (bar/beat): pause-only, independent of editor overlay
    // --------------------------------------------------
    if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED)
    {
        var pps_val = scr_timeline_pps();
        if (!is_real(pps_val) || pps_val == 0) pps_val = 1;

        var ticks_per_beat = 16;
        if (variable_global_exists("TICKS_PER_BEAT") && is_real(global.TICKS_PER_BEAT) && global.TICKS_PER_BEAT > 0)
            ticks_per_beat = floor(global.TICKS_PER_BEAT);

        var left_time  = now_time + (0 - global.HIT_X_GUI) / pps_val;
        var right_time = now_time + (gw - global.HIT_X_GUI) / pps_val;

        var left_tick  = scr_time_to_tick(left_time) - 8;
        var right_tick = scr_time_to_tick(right_time) + 8;

        var ticks_per_bar = ticks_per_beat * 4;
        var step_ticks = 1;
        if (variable_global_exists("editor_grid_step_ticks") && is_real(global.editor_grid_step_ticks) && global.editor_grid_step_ticks > 0)
            step_ticks = floor(global.editor_grid_step_ticks);

        var start_tick = left_tick - (left_tick mod step_ticks);

        for (var tick_i = start_tick; tick_i <= right_tick; tick_i += step_ticks)
        {
            var t_sec = scr_tick_to_time(tick_i);
            var grid_gx = scr_note_screen_x(t_sec, now_time);

            if (grid_gx < 0 || grid_gx > gw) continue;

            var is_bar  = ((tick_i mod ticks_per_bar) == 0);
            var is_beat = ((tick_i mod ticks_per_beat) == 0);

            if (is_bar)
            {
                draw_set_alpha(1);
                draw_set_color(c_black);
                draw_line_width(grid_gx, 40, grid_gx, gh - 140, 2);

                var bar_num = floor(tick_i / ticks_per_bar) + 1;
                if (bar_num < 1) bar_num = 1;
                draw_text(grid_gx + 6, 45, string(bar_num));
            }
            else if (is_beat)
            {
                draw_set_alpha(1);
                draw_set_color(make_color_rgb(180, 180, 180));
                draw_line_width(grid_gx, 40, grid_gx, gh - 140, 1);
            }
        }
    }

    // --------------------------------------------------
    // HITLINE (thick + red + glow + BEAT PULSE)  [PLAY MODE]
    // --------------------------------------------------
    var hit_x = (variable_global_exists("HIT_X_GUI") ? global.HIT_X_GUI : 448);


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


    if (global.dbg_song_overlay_on && script_exists(scr_song_debug_draw)) {
        scr_song_debug_draw(20, 80);
    }

    if (!variable_global_exists("chart") || is_undefined(global.chart)) return;

    var chart_len = array_length(global.chart);

    // Notes
    for (var i = 0; i < chart_len; i++)
    {
        var nref = global.chart[i];

        if (script_exists(scr_note_is_editor_only) && scr_note_is_editor_only(nref.act)) continue;

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

        // Cull far off-screen
        if (start_gx < -400) continue;
        if (start_gx > gw + 400) continue;

        var note_alpha = (variable_struct_exists(nref, "hit") && nref.hit) ? 0.5 : 1.0;
        var alpha_arg = 1;

        // Choose sprite per action (falls back to spr_note if missing)
        var note_act = string_lower(string(nref.act));


        var spr = scr_note_sprite(note_act);

        var note_col = c_white;
        if (script_exists(scr_note_draw_color)) note_col = scr_note_draw_color(nref.act);


        // Animated subimages
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

            draw_set_color(note_col);
            draw_line_width(start_gx, start_gy, end_gx, start_gy, 6);

            // Hold end marker
            draw_set_alpha(global.hold_end_alpha);
            if (spr != -1) {
                draw_set_alpha(note_alpha);
                draw_sprite_ext(spr, subimg_end, end_gx, start_gy, 1, 1, 0, note_col, alpha_arg);
                draw_set_alpha(1);
            }
            else {
                draw_set_color(note_col);
                draw_rectangle(end_gx - 10, start_gy - 10, end_gx + 10, start_gy + 10, false);
            }
            draw_set_alpha(1);
        }


        // Start note marker
        if (spr != -1) {
            draw_set_alpha(note_alpha);
            draw_sprite_ext(spr, subimg_start, start_gx, start_gy, 1, 1, 0, note_col, alpha_arg);
            draw_set_alpha(1);
        }
        else {
            draw_set_color(note_col);
            draw_rectangle(start_gx - 10, start_gy - 10, start_gx + 10, start_gy + 10, false);
            draw_set_color(c_black);
        }

    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
    shader_reset();
}
