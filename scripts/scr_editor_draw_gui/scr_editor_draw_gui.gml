function scr_editor_draw_gui()
{
    // ==================================================
    // SAFETY INIT (prevents crashes if globals init didn't run yet)
    // ==================================================
    if (!variable_global_exists("editor_phrase_sel"))      global.editor_phrase_sel = -1;
    if (!variable_global_exists("editor_phrase_step_sel")) global.editor_phrase_step_sel = 0;
    if (!variable_global_exists("phrases"))               global.phrases = [];
    if (!variable_global_exists("editor_on"))             global.editor_on = false;
if (!variable_global_exists("timeline_zoom") || !is_real(global.timeline_zoom)) global.timeline_zoom = 1.0;
    if (!variable_global_exists("markers"))               global.markers = [];
    if (!variable_global_exists("editor_marker_sel"))     global.editor_marker_sel = -1;
    if (!variable_global_exists("editor_marker_drag"))    global.editor_marker_drag = false;
    if (!variable_global_exists("editor_marker_drag_dx")) global.editor_marker_drag_dx = 0;

    if (!variable_global_exists("editor_act"))            global.editor_act = "jump";
    if (!variable_global_exists("sel"))                   global.sel = [];
    if (!variable_global_exists("hold_end_alpha"))        global.hold_end_alpha = 0.4;
    if (!variable_global_exists("CHART_TIME_OFFSET_S"))   global.CHART_TIME_OFFSET_S = 0;
    if (!variable_global_exists("TICKS_PER_BEAT"))        global.TICKS_PER_BEAT = 16;
    if (!variable_global_exists("editor_grid_step_ticks"))global.editor_grid_step_ticks = 1;


    // ==================================================
    // BASICS / DRAW STATE RESET
    // ==================================================
    var now_time = scr_chart_time();
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);


    // ==================================================
    // QUICK DEBUG HUD (top-left / misc)
    // ==================================================
    draw_text(500, 40, "Chart: " + string(global.chart_file));

    // chart length debug (keep exact behavior)
    draw_set_color(c_black);
    draw_text(20, 250, "chart count: " + string(array_length(global.chart)));


    // ==================================================
    // MODE / OFFSETS HUD
    // ==================================================
    draw_set_alpha(1);
    draw_set_color(c_white);

    draw_text(20, gui_h - 140,
        "MODE: " + string(global.editor_act) +
        "   (Shift+1=Atk1 Shift+2=Atk2 Shift+3=Atk3 Shift+4=Ult Shift+5=Jump Shift+6=Duck)"
    );

    draw_text(10, 160,
        "Chart Offset: " + string_format(global.CHART_TIME_OFFSET_S, 1, 4) + " s"
    );


    // ==================================================
    // TIMELINE GRID (tick-stable) + MEASURE NUMBERS
    // ==================================================
    // Requires:
    // scr_time_to_tick(), scr_tick_to_time(), scr_timeline_pps(), scr_note_screen_x()

    var pps_val = scr_timeline_pps();

    // Visible time range based on zoom
    var _pps_denom = pps_val;
    if (_pps_denom == 0) {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        _pps_denom = 1;
    }
    var left_time  = now_time + (0 - global.HIT_X_GUI) / _pps_denom;
    var right_time = now_time + (gui_w - global.HIT_X_GUI) / _pps_denom;

    var left_tick  = scr_time_to_tick(left_time) - 8;
    var right_tick = scr_time_to_tick(right_time) + 8;

    // 4/4 assumption: 4 beats per bar
    var ticks_per_bar = global.TICKS_PER_BEAT * 4;

    var step_ticks = max(1, global.editor_grid_step_ticks);

    // Align start tick so the grid doesn't "crawl"
    var start_tick = left_tick - (left_tick mod step_ticks);

    var show_divisions = (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED);
    if (show_divisions)
    {
        for (var tick_i = start_tick; tick_i <= right_tick; tick_i += step_ticks)
        {
            var t_sec = scr_tick_to_time(tick_i);
            var grid_gx = scr_note_screen_x(t_sec, now_time);

            if (grid_gx < 0 || grid_gx > gui_w) continue;

            var is_bar  = ((tick_i mod ticks_per_bar) == 0);
            var is_beat = ((tick_i mod global.TICKS_PER_BEAT) == 0);

            if (is_bar)
            {
                // Bar line
                draw_set_alpha(1);
                draw_set_color(c_black);
                draw_line_width(grid_gx, 40, grid_gx, gui_h - 140, 2);

                // Measure number (1-based)
                var _bar_ticks_denom = ticks_per_bar;
                if (_bar_ticks_denom == 0) {
                    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
                    _bar_ticks_denom = 1;
                }
                var bar_num = floor(tick_i / _bar_ticks_denom) + 1;
                if (bar_num < 1) bar_num = 1;

                draw_set_color(c_black);
                draw_text(grid_gx + 6, 45, string(bar_num));
            }
            else if (is_beat)
            {
                // Beat line
                draw_set_alpha(1);
                draw_set_color(make_color_rgb(180, 180, 180));
                draw_line_width(grid_gx, 40, grid_gx, gui_h - 140, 1);
            }
        }
    }


    // ==================================================
    // STORY MARKERS (pause/diff/spawn/camera)
    // ==================================================
    if (variable_global_exists("markers") && is_array(global.markers))
    {
        var pps_m = scr_timeline_pps();
        var top_y = 40;
        var bot_y = gui_h - 140;

        for (var mi = 0; mi < array_length(global.markers); mi++)
        {
            var m = global.markers[mi];
            if (!is_struct(m)) continue;
            if (!variable_struct_exists(m, "t")) continue;

            var gx = global.HIT_X_GUI + (m.t - now_time) * pps_m;
            if (gx < 0 || gx > gui_w) continue;

            var mt = (variable_struct_exists(m, "type") ? string(m.type) : "pause");
            var is_spawn = (mt == "spawn");
            var is_diff  = (mt == "difficulty" || mt == "diff");
            var is_camera = (mt == "camera");

            // --- Main vertical line (for all non-spawn markers) ---
            if (!is_spawn)
            {
                if (mi == global.editor_marker_sel)
                {
                    draw_set_alpha(1);
                    if (is_camera) draw_set_color(make_color_rgb(0, 255, 255));
                    else draw_set_color(c_fuchsia);
                    draw_line_width(gx, top_y, gx, bot_y, (is_camera ? 6 : 4));
                }
                else
                {
                    draw_set_alpha(0.85);
                    if (is_camera) draw_set_color(make_color_rgb(120, 220, 255));
                    else draw_set_color(make_color_rgb(200, 120, 255));
                    draw_line_width(gx, top_y, gx, bot_y, 2);
                }
            }

            // --- Marker-specific visuals / label ---
            if (is_spawn)
            {
                // Spawn marker: small indicator at y_gui
                var yy = (variable_struct_exists(m, "y_gui") && is_real(m.y_gui)) ? m.y_gui : (top_y + 20);

                draw_set_alpha(1);
                draw_set_color((mi == global.editor_marker_sel) ? c_yellow : c_lime);

                // tiny vertical tick + circle
                draw_line_width(gx, yy - 18, gx, yy + 18, (mi == global.editor_marker_sel) ? 4 : 2);
                draw_circle(gx, yy, 6, false);

                draw_set_color(c_white);
                var ek = (variable_struct_exists(m, "enemy_kind")) ? string(m.enemy_kind) : "poptarts";
                draw_text(gx + 8, yy - 10, "SPAWN  " + ek);
            }
            else
            {
                draw_set_alpha(1);
                draw_set_color(c_white);

                if (is_diff)
                {
                    var d = (variable_struct_exists(m, "diff") ? string(m.diff) : "normal");
                    draw_text(gx + 6, top_y + 8, "DIFF  " + string_upper(d));
                }
                else if (is_camera)
                {
                    var czoom = (variable_struct_exists(m, "zoom") ? string_format(real(m.zoom), 1, 2) : "1.00");
                    var cpx = (variable_struct_exists(m, "pan_x") ? string(round(real(m.pan_x))) : "0");
                    var cpy = (variable_struct_exists(m, "pan_y") ? string(round(real(m.pan_y))) : "0");
                    var ce = (variable_struct_exists(m, "ease") ? string_upper(string(m.ease)) : "SMOOTH");
                    draw_text(gx + 6, top_y + 8, "CAM z" + czoom + " x" + cpx + " y" + cpy + " " + ce);
                }
                else
                {
                    // Pause marker label
                    var label = "PAUSE";
                    if (variable_struct_exists(m, "snd_name")) label += "  " + string(m.snd_name);
                    if (variable_struct_exists(m, "wait_confirm") && m.wait_confirm) label += "  (confirm)";
                    if (variable_struct_exists(m, "loop") && m.loop) label += "  (loop)";
                    if (variable_struct_exists(m, "choices") && is_array(m.choices) && array_length(m.choices) > 0) label += "  (choice)";
                    draw_text(gx + 6, top_y + 8, label);
                }
            }
        }

        draw_set_alpha(1);
        draw_set_color(c_black);
    }


    // ==================================================
    // SELECTED MARKER DEBUG (bottom line)
    // ==================================================
    if (global.editor_marker_sel >= 0 && global.editor_marker_sel < array_length(global.markers))
    {
        var msel = global.markers[global.editor_marker_sel];
        var s = "MARKER sel=" + string(global.editor_marker_sel);

        if (is_struct(msel))
        {
            var mt2 = (variable_struct_exists(msel, "type") ? string(msel.type) : "");
            if (variable_struct_exists(msel, "type")) s += " type=" + mt2;
            if (variable_struct_exists(msel, "t"))    s += " t=" + string_format(msel.t, 0, 3);

            if (mt2 == "spawn")
            {
                if (variable_struct_exists(msel, "enemy_kind")) s += " enemy=" + string(msel.enemy_kind);
                if (variable_struct_exists(msel, "y_gui"))      s += " y=" + string(floor(msel.y_gui));
                if (variable_struct_exists(msel, "lane"))       s += " lane=" + string(msel.lane);
            }
            else if (mt2 == "difficulty" || mt2 == "diff")
            {
                if (variable_struct_exists(msel, "diff"))    s += " diff=" + string(msel.diff);
                if (variable_struct_exists(msel, "caption")) s += " caption=" + string(msel.caption);
            }
            else if (mt2 == "camera")
            {
                if (variable_struct_exists(msel, "zoom")) s += " zoom=" + string_format(real(msel.zoom), 1, 2);
                if (variable_struct_exists(msel, "pan_x")) s += " pan_x=" + string(round(real(msel.pan_x)));
                if (variable_struct_exists(msel, "pan_y")) s += " pan_y=" + string(round(real(msel.pan_y)));
                if (variable_struct_exists(msel, "ease"))  s += " ease=" + string(msel.ease);
            }
            else
            {
                if (variable_struct_exists(msel, "snd_name")) s += " snd=" + string(msel.snd_name);
                if (variable_struct_exists(msel, "caption"))  s += " caption=" + string(msel.caption);

                if (variable_struct_exists(msel, "choices") && is_array(msel.choices))
                    s += " choices=" + string(array_length(msel.choices));
            }
        }

        draw_set_color(c_white);
        draw_text(20, display_get_gui_height() - 30, s);
    }


    // ==================================================
    // HITLINE (thick + red + glow)
    // ==================================================
    var hit_x = (variable_global_exists("HIT_X_GUI") ? global.HIT_X_GUI : 448);

    var y0 = 0;
    var y1 = display_get_gui_height();

    var core_w  = 6;
    var glow_w1 = 18;
    var glow_w2 = 36;
    var glow_w3 = 60;

    var core_col = make_color_rgb(255, 40, 40);
    var glow_col = make_color_rgb(255, 70, 70);

    gpu_set_blendmode(bm_add);
    draw_set_color(glow_col);

    draw_set_alpha(0.06);
    draw_rectangle(hit_x - glow_w3 * 0.5, y0, hit_x + glow_w3 * 0.5, y1, false);

    draw_set_alpha(0.12);
    draw_rectangle(hit_x - glow_w2 * 0.5, y0, hit_x + glow_w2 * 0.5, y1, false);

    draw_set_alpha(0.20);
    draw_rectangle(hit_x - glow_w1 * 0.5, y0, hit_x + glow_w1 * 0.5, y1, false);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(core_col);
    draw_rectangle(hit_x - core_w * 0.5, y0, hit_x + core_w * 0.5, y1, false);

    draw_set_alpha(1);
    draw_set_color(c_black);


    // ==================================================
    // SELECTION HIGHLIGHTS + HOLD VISUALS
    // ==================================================
    if (variable_global_exists("chart") && is_array(global.chart))
    {
        for (var si = 0; si < array_length(global.sel); si++)
        {
            var idx = global.sel[si];
            if (idx < 0 || idx >= array_length(global.chart)) continue;

            var note_ref = global.chart[idx];
            var p = scr_editor_note_gui_pos(note_ref, now_time);

            // Highlight ring
            draw_set_alpha(1);
            draw_set_color(c_aqua);
            draw_circle(p.gx, p.gy, 26, false);

            // Hold body + end marker
            if (note_ref.type == "hold")
            {
                var end_t = note_ref.t + note_ref.dur;
                var end_gx = scr_note_screen_x(end_t, now_time);
                var end_gy = p.gy;

                // Body line
                var note_col = c_white;
                if (script_exists(scr_note_draw_color)) note_col = scr_note_draw_color(note_ref.act);

                draw_set_alpha(1);
                draw_set_color(note_col);
                draw_line_width(p.gx, p.gy, end_gx, end_gy, 6);

                // End ghost sprite
                draw_set_alpha(global.hold_end_alpha);
                var spr = scr_note_sprite(note_ref.act);
                var subimg = scr_anim_subimg(spr, idx);
                var alpha_arg = 1;
                var note_act = string_lower(string(note_ref.act));
                var debug_note_alpha = (variable_global_exists("DEBUG_NOTE_ALPHA") && global.DEBUG_NOTE_ALPHA);
                var is_atk3 = (note_act == "atk3");

                if (debug_note_alpha && is_atk3)
                {
                    var dbg_a_state = draw_get_alpha();
                    var dbg_col = draw_get_color();
                    var dbg_bm = gpu_get_blendmode();
                    show_debug_message("[ATK3_ALPHA_EDITOR] act=" + note_act
                        + " was_hit=0"
                        + " note_a=" + string_format(global.hold_end_alpha, 1, 3)
                        + " a_state=" + string_format(dbg_a_state, 1, 3)
                        + " color=" + string(dbg_col)
                        + " bm=" + string(dbg_bm)
                        + " shader=n/a"
                        + " a_arg=" + string_format(alpha_arg, 1, 3));

                    draw_set_alpha(1);
                    draw_set_color(c_yellow);
                    draw_text(end_gx + 24, end_gy - 34,
                        "ATK3 a_state=" + string_format(dbg_a_state, 1, 2)
                        + " a_arg=" + string_format(alpha_arg, 1, 2)
                        + " was_hit=0"
                        + " note_a=" + string_format(global.hold_end_alpha, 1, 2)
                        + " bm=" + string(dbg_bm));

                    gpu_set_blendmode(bm_normal);
                    draw_set_alpha(1);
                    draw_set_color(c_white);
                    draw_sprite(scr_note_sprite("atk3"), 0, end_gx + 80, end_gy);

                    draw_set_alpha(global.hold_end_alpha);
                    draw_set_color(note_col);
                    gpu_set_blendmode(bm_normal);
                }

                draw_sprite_ext(spr, subimg, end_gx, end_gy, 1, 1, 0, note_col, alpha_arg);

                draw_set_alpha(1);
            }
        }
    }


    // ==================================================
    // MARQUEE SELECTION RECT
    // ==================================================
    if (variable_global_exists("drag_marquee") && is_struct(global.drag_marquee) && global.drag_marquee.active)
    {
        var ax = global.drag_marquee.a_gui_x;
        var ay = global.drag_marquee.a_gui_y;
        var bx = global.drag_marquee.b_gui_x;
        var by = global.drag_marquee.b_gui_y;

        var l = min(ax, bx);
        var r = max(ax, bx);
        var t = min(ay, by);
        var b = max(ay, by);

        draw_set_alpha(1);
        draw_set_color(c_yellow);
        draw_rectangle(l, t, r, b, false);
    }


    // ==================================================
    // EDITOR HUD (bottom-left lines)
    // ==================================================
    draw_set_alpha(1);
    draw_set_color(c_lime);

    var snap_state = (variable_global_exists("editor_snap_on") && global.editor_snap_on) ? "ON" : "OFF";

    draw_text(20, gui_h - 120, "EDITOR (SPACE exit)  Tool: " + string(global.editor_tool) + "  (Y=Phrase, M=Marker)");
    draw_text(20, gui_h - 100, "Grid: 1/16 tick-stable  | Snap: " + snap_state);
    draw_text(20, gui_h - 80,  "Timeline Zoom: " + string_format(global.timeline_zoom, 1, 2) + "  (pps=" + string(round(scr_timeline_pps())) + ")");
    draw_text(20, gui_h - 60,  "LMB drag/select | Drag box select | RMB delete | Ctrl+C/V/D | [ ] zoom chart");


    // ==================================================
    // SELECTED MARKER CAPTION LINE (the long one)
    // ==================================================
    if (variable_global_exists("editor_marker_sel") && global.editor_marker_sel >= 0
        && variable_global_exists("markers") && global.editor_marker_sel < array_length(global.markers))
    {
        var m = global.markers[global.editor_marker_sel];

        var cap  = (is_struct(m) && variable_struct_exists(m, "caption")) ? string(m.caption) : "(no caption)";
        var mtyp = (is_struct(m) && variable_struct_exists(m, "type"))    ? string(m.type)    : "(no type)";
        var mdif = (is_struct(m) && variable_struct_exists(m, "diff"))    ? string(m.diff)    : "(no diff)";
        var mswp = (is_struct(m) && variable_struct_exists(m, "swap") && is_string(m.swap)) ? string(m.swap) : "(no swap)";

        var swp_disp = string_lower(mswp);
        if (swp_disp != "audio" && swp_disp != "visual" && swp_disp != "both") swp_disp = "both";

        var show_swap = false;
        if (is_struct(m))
        {
            var mt = string_lower(string(mtyp));
            if (mt == "difficulty" || mt == "diff") show_swap = true;
            if (variable_struct_exists(m, "diff"))  show_swap = true;
        }

        draw_set_color(c_white);

        var line = "Marker Caption: " + cap + "   (C/V to cycle)"
                 + "   Type: " + mtyp
                 + "   Diff: " + mdif;

        if (show_swap)
            line += "   Swap: " + string_upper(swp_disp) + "   (Shift+D to cycle)";
        else
            line += "   Swap: (not a diff marker)";

        draw_text(20, gui_h - 40, line);
    }
    else
    {
        draw_set_color(c_white);
        draw_text(20, gui_h - 40, "Marker Caption: (none selected)");
    }


    // ==================================================
    // NEAREST NOTE INFO @ current editor time
    // ==================================================
    if (variable_global_exists("chart") && is_array(global.chart))
    {
        var t_now = now_time;
        var best_i = -1;
        var best_dt = 999999;

        for (var i2 = 0; i2 < array_length(global.chart); i2++)
        {
            var n = global.chart[i2];
            var dt = abs(n.t - t_now);
            if (dt < best_dt) { best_dt = dt; best_i = i2; }
        }

        if (best_i >= 0 && best_dt <= 0.25)
        {
            var nn = global.chart[best_i];
            var act = (variable_struct_exists(nn, "act")) ? nn.act : "none";

            draw_set_alpha(1);
            draw_set_color(c_black);
            draw_text(20, gui_h - 160,
                "Nearest: i=" + string(best_i) +
                "  t=" + string_format(nn.t, 0, 3) +
                "  act=" + string(act) +
                "  type=" + string(nn.type)
            );
        }
    }


    // ==================================================
    // MARKER KEYBINDS DEBUG PANEL (F3 toggle)
    // ==================================================
    if (variable_global_exists("dbg_marker_keys_on") && global.dbg_marker_keys_on)
    {
        var gw = display_get_gui_width();
        var gh = display_get_gui_height();

        var margin = 16;
        var px = margin;
        var pw = gw - margin * 2;
        var py = 200;
        var ph = min(700, gh - py - margin);

        // Tweak these to tune panel layout and scrolling feel.
        var panel_pad = 10;
        var header_h = 28;
        var line_h = 18;
        var text_top_pad = 6;
        var text_bottom_pad = 10;
        var col_gap = 8;
        var scrollbar_pad = 10;
        var scrollbar_w = 12;
        var min_thumb = 28;

        var txtL = variable_global_exists("dbg_marker_txtL") ? global.dbg_marker_txtL : "";
        var txtR = variable_global_exists("dbg_marker_txtR") ? global.dbg_marker_txtR : "";

        var left_lines = string_count("\n", txtL) + 1;
        var right_lines = string_count("\n", txtR) + 1;
        var line_count = max(left_lines, right_lines);
        var content_h = text_top_pad + (line_count * line_h) + text_bottom_pad;

        var view_x = px + panel_pad;
        var view_y = py + header_h;
        var view_w = pw - panel_pad * 2 - scrollbar_w - scrollbar_pad * 2;
        var view_h = max(1, ph - header_h - panel_pad);

        var max_scroll = max(0, content_h - view_h);
        var scroll_y = variable_global_exists("dbg_marker_scroll_y") ? clamp(global.dbg_marker_scroll_y, 0, max_scroll) : 0;
        global.dbg_marker_scroll_y = scroll_y;

        var track_x = px + pw - scrollbar_pad - scrollbar_w;
        var track_y = view_y;
        var track_h = view_h;
        var thumb_h = max(min_thumb, track_h * (view_h / max(1, content_h)));
        thumb_h = min(track_h, thumb_h);
        var thumb_move = max(1, track_h - thumb_h);
        var thumb_y = track_y;
        if (max_scroll > 0) {
            var _scroll_denom = max_scroll;
            if (_scroll_denom == 0) {
                show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
                _scroll_denom = 1;
            }
            thumb_y = track_y + ((scroll_y / _scroll_denom) * thumb_move);
        }

        // Panel frame + header are fixed; only text region scrolls.
        draw_set_alpha(1);
        draw_set_color(c_black);
        draw_rectangle(px, py, px + pw, py + ph, false);

        draw_set_color(make_color_rgb(30, 30, 30));
        draw_rectangle(px + 1, py + 1, px + pw - 1, py + header_h, false);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(make_color_rgb(240, 120, 255));

        // Clip text using a surface so only the interior region scrolls.
        var clip_surf = surface_create(max(1, floor(view_w)), max(1, floor(view_h)));
        if (surface_exists(clip_surf)) {
            surface_set_target(clip_surf);
            draw_clear_alpha(c_black, 0);

            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(make_color_rgb(240, 120, 255));

            var col_w = floor((view_w - col_gap) / 2);
            var draw_y = text_top_pad - scroll_y;
            draw_text(0, draw_y, txtL);
            draw_text(col_w + col_gap, draw_y, txtR);

            surface_reset_target();
            draw_surface(clip_surf, view_x, view_y);
            surface_free(clip_surf);
        }

        // Scrollbar track + thumb.
        draw_set_color(make_color_rgb(55, 55, 55));
        draw_rectangle(track_x, track_y, track_x + scrollbar_w, track_y + track_h, false);

        draw_set_color(make_color_rgb(210, 120, 245));
        draw_rectangle(track_x, thumb_y, track_x + scrollbar_w, thumb_y + thumb_h, false);

        draw_set_color(c_white);
        draw_rectangle(px, py, px + pw, py + ph, true);

        global.dbg_marker_content_h = content_h;
        global.dbg_marker_view_h = view_h;
        global.dbg_marker_track_y = track_y;
        global.dbg_marker_track_h = track_h;
        global.dbg_marker_thumb_h = thumb_h;
    }


    // ==================================================
    // BG DEBUG @ HITLINE (toggle B)
    // ==================================================
    if (variable_global_exists("dbg_bg_hit") && global.dbg_bg_hit)
    {
        var cm = instance_find(obj_chunk_manager, 0);

        var pps = (variable_global_exists("WORLD_PPS") ? global.WORLD_PPS : 0);
        if (pps <= 0) pps = 1;

        var chunk_w_px = global.CHUNK_W_TILES * global.TILE_W;

        var ed_on = (variable_global_exists("editor_on") && global.editor_on);
        var t_now2 = ed_on ? scr_chart_time() : scr_song_time();
        if (!is_real(t_now2) || is_nan(t_now2)) t_now2 = 0;

        var xoff = (variable_global_exists("CHUNK_X_OFFSET_PX") ? global.CHUNK_X_OFFSET_PX : 0);
        var x_now_map = t_now2 * pps + xoff;

        var _chunk_w_denom = chunk_w_px;
        if (_chunk_w_denom == 0) {
            show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
            _chunk_w_denom = 1;
        }
        var ci = floor(x_now_map / _chunk_w_denom);
        if (ci < 0) ci = 0;

        var slot = -1;
        if (cm != noone && variable_instance_exists(cm, "slot_ci") && is_array(cm.slot_ci))
        {
            for (var s2 = 0; s2 < array_length(cm.slot_ci); s2++)
            {
                if (cm.slot_ci[s2] == ci) { slot = s2; break; }
            }
        }

        var sprN = -1;
        var sprF = -1;

        if (slot >= 0)
        {
            if (variable_global_exists("bg_slot_near") && is_array(global.bg_slot_near) && slot < array_length(global.bg_slot_near))
                sprN = global.bg_slot_near[slot];

            if (variable_global_exists("bg_slot_far") && is_array(global.bg_slot_far) && slot < array_length(global.bg_slot_far))
                sprF = global.bg_slot_far[slot];
        }

        if (script_exists(scr_bg_debug_reverse_init)) scr_bg_debug_reverse_init();

        var nameN = "(none)";
        var nameF = "(none)";

        if (sprN != -1 && variable_global_exists("bg_dbg_rev_near") && ds_exists(global.bg_dbg_rev_near, ds_type_map) && ds_map_exists(global.bg_dbg_rev_near, sprN))
            nameN = global.bg_dbg_rev_near[? sprN] + " (id " + string(sprN) + ")";
        else if (sprN != -1)
            nameN = "id " + string(sprN);

        if (sprF != -1 && variable_global_exists("bg_dbg_rev_far") && ds_exists(global.bg_dbg_rev_far, ds_type_map) && ds_map_exists(global.bg_dbg_rev_far, sprF))
            nameF = global.bg_dbg_rev_far[? sprF] + " (id " + string(sprF) + ")";
        else if (sprF != -1)
            nameF = "id " + string(sprF);

        var room_name = "(unknown)";
        if (cm != noone && slot >= 0 && variable_instance_exists(cm, "slot_room_name") && is_array(cm.slot_room_name) && slot < array_length(cm.slot_room_name))
            room_name = string(cm.slot_room_name[slot]);

        draw_set_color(c_black);
        draw_text(20, gui_h * 0.66,
            "BG@Hitline  t=" + string_format(t_now2, 2, 3)
            + "  ci=" + string(ci)
            + "  slot=" + string(slot)
            + "\nchunk=" + room_name
            + "\nNEAR=" + nameN
            + "\nFAR =" + nameF
        );
    }


    // ==================================================
    // SELECTED PHRASE HIGHLIGHT (phrase tool)
    // ==================================================
    if (variable_global_exists("editor_phrase_sel")
    && variable_global_exists("phrases")
    && global.editor_phrase_sel >= 0
    && global.editor_phrase_sel < array_length(global.phrases))
    {
        var phs = global.phrases[global.editor_phrase_sel];
        var pps_val2 = scr_timeline_pps();

        for (var psi = 0; psi < array_length(phs.steps); psi++)
        {
            var st = phs.steps[psi];
            var step_time = phs.t + st.dt;

            var gx2 = global.HIT_X_GUI + (step_time - now_time) * pps_val2;
            var lane_i = clamp(st.b - 1, 0, 3);
            var gy2 = global.LANE_Y[lane_i];

            draw_set_alpha(1);
            draw_set_color((psi == global.editor_phrase_step_sel) ? c_yellow : c_aqua);
            draw_circle(gx2, gy2, 24, false);
        }

        draw_set_alpha(1);
        draw_set_color(c_black);
        draw_text(20, gui_h - 30,
            "Phrase tool: Y toggle | Select step: click | 1-4 button | <-/-> shift by 1/16 | N add | Backspace delete"
        );
    }


    // ==================================================
    // MARKER PRESET DEBUG (top-left)
    // ==================================================
    if (variable_global_exists("dbg_marker_preset") && string_length(global.dbg_marker_preset) > 0)
    {
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_text(20, 20, "Marker preset [" + string(global.dbg_marker_preset_i) + "]: " + global.dbg_marker_preset);
    }


    // ==================================================
    // marker_sel + caption line (bottom)
    // ==================================================
    draw_set_color(c_white);
    draw_text(20, gui_h - 20,
        "marker_sel=" + string(global.editor_marker_sel) +
        (global.editor_marker_sel >= 0 && global.editor_marker_sel < array_length(global.markers)
            ? (" caption=" + (variable_struct_exists(global.markers[global.editor_marker_sel], "caption")
                ? string(global.markers[global.editor_marker_sel].caption)
                : "<none>"))
            : "")
    );


    // ==================================================
    // GHOST ENEMY PREVIEW (EDITOR ON)
    // ==================================================
    if (global.editor_on && variable_global_exists("markers") && is_array(global.markers))
    {
        var now_t3 = global.editor_time;
        var gw3 = display_get_gui_width();

        for (var i3 = 0; i3 < array_length(global.markers); i3++)
        {
            var m3 = global.markers[i3];
            if (!is_struct(m3)) continue;

            if (!variable_struct_exists(m3, "type") || string(m3.type) != "spawn") continue;
            if (!variable_struct_exists(m3, "t") || !is_real(m3.t)) continue;

            var xg = scr_note_screen_x(m3.t, now_t3);
            if (xg < -200 || xg > gw3 + 200) continue;

            var yg = 0;
            if (variable_struct_exists(m3, "y_gui") && is_real(m3.y_gui)) yg = m3.y_gui;
            else yg = display_get_gui_height() * 0.5;

            var ek3 = variable_struct_exists(m3, "enemy_kind") ? m3.enemy_kind : "poptart";
            var spr3 = scr_enemy_sprite_from_kind(ek3);
            if (spr3 == -1) spr3 = asset_get_index("spr_poptart");

            draw_set_alpha(0.35);
            if (spr3 != -1) {
                draw_sprite(spr3, 0, xg, yg - 48);
            } else {
                draw_set_color(c_white);
                draw_rectangle(xg - 20, yg - 70, xg + 20, yg - 30, false);
            }

            draw_set_alpha(0.5);
            draw_set_color(c_white);
            var ek_lbl = variable_struct_exists(m3, "enemy_kind") ? string(m3.enemy_kind) : "poptarts";
            draw_text(xg + 10, yg - 80, ek_lbl);

            draw_set_alpha(1);
        }
    }

	// ==================================================
	// GHOST PICKUP PREVIEW (EDITOR ON)
	// ==================================================
	if (global.editor_on && variable_global_exists("markers") && is_array(global.markers))
	{
	    var now_t4 = global.editor_time;
	    var gw4 = display_get_gui_width();

	    for (var i4 = 0; i4 < array_length(global.markers); i4++)
	    {
	        var m4 = global.markers[i4];
	        if (!is_struct(m4)) continue;

	        if (!variable_struct_exists(m4, "type") || string(m4.type) != "pickup") continue;
	        if (!variable_struct_exists(m4, "t") || !is_real(m4.t)) continue;

	        var xg4 = scr_note_screen_x(m4.t, now_t4);
	        if (xg4 < -200 || xg4 > gw4 + 200) continue;

	        var yg4 = (variable_struct_exists(m4, "y_gui") && is_real(m4.y_gui))
	            ? m4.y_gui
	            : display_get_gui_height() * 0.5;

	        var pk = (variable_struct_exists(m4, "pickup_kind") ? string_lower(string(m4.pickup_kind)) : "shard");

	        // Try to find a sprite named spr_pickup_chart/eyes/shard; fallback to text box.
	        var sprp = asset_get_index("spr_pickup_" + pk);

	        draw_set_alpha(0.35);
	        if (sprp != -1) {
	            draw_sprite(sprp, 0, xg4, yg4 - 24);
	        } else {
	            draw_set_color(c_white);
	            draw_rectangle(xg4 - 18, yg4 - 42, xg4 + 18, yg4 - 6, false);
	        }

	        draw_set_alpha(0.6);
	        draw_set_color(c_white);
	        draw_text(xg4 + 10, yg4 - 50, pk);

	        draw_set_alpha(1);
	    }
	}

    // ==================================================
    // RESTORE DRAW STATE
    // ==================================================
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
    shader_reset();
}
