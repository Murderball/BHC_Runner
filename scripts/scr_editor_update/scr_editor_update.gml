function scr_editor_update() {
    // --------------------------------------------------
    // SAFETY INIT (must run before any editor_time reads)
    // --------------------------------------------------
    if (!variable_global_exists("GLOBALS_INITIALIZED") || !global.GLOBALS_INITIALIZED) return;

    if (!variable_global_exists("editor_time") || is_undefined(global.editor_time)) {
        global.editor_time = 0.0;
    }
    if (!variable_global_exists("editor_tool") || is_undefined(global.editor_tool)) {
        global.editor_tool = "tap";
    }
    if (!variable_global_exists("editor_snap_on") || is_undefined(global.editor_snap_on)) {
        global.editor_snap_on = true;
    }
	// Toggle marker keybind debug panel (F3)
	if (!variable_global_exists("dbg_marker_keys_on")) global.dbg_marker_keys_on = false;
	if (!variable_global_exists("dbg_marker_scroll_y")) global.dbg_marker_scroll_y = 0;
	if (!variable_global_exists("dbg_marker_dragging_thumb")) global.dbg_marker_dragging_thumb = false;
	if (!variable_global_exists("dbg_marker_drag_offset")) global.dbg_marker_drag_offset = 0;
	if (!variable_global_exists("dbg_marker_content_h")) global.dbg_marker_content_h = 0;
	if (!variable_global_exists("dbg_marker_view_h")) global.dbg_marker_view_h = 0;
	if (!variable_global_exists("dbg_marker_thumb_h")) global.dbg_marker_thumb_h = 0;
	if (!variable_global_exists("dbg_marker_track_y")) global.dbg_marker_track_y = 0;
	if (!variable_global_exists("dbg_marker_track_h")) global.dbg_marker_track_h = 0;


	if (!variable_global_exists("dbg_marker_txtL")) {
	    global.dbg_marker_txtL =
		 "MARKER TOOL (active):\n" +
			"  Z / X          marker place type prev/next\n" +
	        "  Ctrl+S         save markers\n" +
	        "  Ctrl+L         load markers\n" +
	        "  LMB            select / create marker\n" +
	        "  LMB-drag       move selected marker time\n" +
	        "  Shift+LMB      create SPAWN marker (enemy)\n" +
			"  Shift+Alt+LMB  create PICKUP marker\n" +
	        "  Alt+LMB        create CAMERA marker\n" +
	        "  Delete/Backsp  delete selected marker\n" +
	        "  RMB            delete marker under mouse\n" +
	        "  Shift+D        Swap Visual/Audio Modes\n" +
		        " F12    :       Toggle Play Window between screens\n" +
	        " Tab    :       Play From Editor\n" +
	        "Esc     :       Pause\n" +
	        "[ or ]  :       Timeline Zoom\n" +
	        "H       :       Tap/Hold Note Toggle\n" +
	        "P       :       Phrase Tool\n" +
	        " F8     :       Toggle Auto Hit\n" +
	        " F11    :       Toggle Chunk Highlighting\n" +
	        " E      :       Export Chunk\n";
	}
	if (!variable_global_exists("dbg_marker_txtR")) {
	    global.dbg_marker_txtR =
	        "GLOBAL / FILE:\n" +
	        "  Ctrl+Shift+M   wipe marker file\n" +
	        "  M              toggle Marker tool\n" +

	        "DIFFICULTY:\n" +
	        "  Ctrl+1/2/3/4   Chart Difficulty Toggle\n" +
	        "  T              Toggle Difficulty Marker\n" +
	        "  U              Toggle Camera Marker\n" +
	        "  Shift+7/8/9    Marker Difficulty Toggle\n" +

	       

	        "SPAWN MARKER (type=spawn):\n" +
	        "  G              cycle enemy_kind\n" +
	        "  Up/Down        nudge y\n" +
	        "  Shift+LMB hold  set y to mouse\n" +
			"  \nPICKUP MARKER (type=pickup):\n" +
			"  J              cycle pickup_kind\n" +
			"  Up/Down        nudge y\n" +
			"  Shift+LMB hold  set y to mouse\n" +
			"  \nROOM GOTO MARKER (type=room_goto):\n" +
			"  Q / E          side room prev/next\n" +
			"  I              convert selected to room_goto\n" +

	        "CAMERA MARKER (type=camera):\n" +
	        "  Q / E          zoom -/+\n" +
	        "  Arrows         pan x/y\n" +
	        "  Shift+Arrows   fast pan x/y\n" +
	        "  C / V          ease prev/next\n" +
	        "  R              reset zoom/pan\n" +

	        "STORY/PAUSE MARKER:\n" +
	        "  N              toggle Yes/No choices\n" +
	        "  R              toggle loop\n" +
	        "  F              toggle wait_confirm\n" +
	        "  C / V          caption preset prev/next\n" +
	        "  O / P          fade out -/+ 50ms\n" +
	        "  K / L          fade in  -/+ 50ms\n" +
	        "  Q / E          sound prev/next\n";
	}

	if (!variable_global_exists("editor_marker_place_types") || !is_array(global.editor_marker_place_types) || array_length(global.editor_marker_place_types) == 0) {
		global.editor_marker_place_types = ["pause", "room_goto", "spawn", "pickup", "camera", "difficulty"];
	}
	if (!variable_global_exists("editor_marker_place_i")) global.editor_marker_place_i = 0;
	global.editor_marker_place_i = clamp(global.editor_marker_place_i, 0, array_length(global.editor_marker_place_types) - 1);


    // Marker caption presets (editor helper list)
    if (!variable_global_exists("marker_caption_presets") || !is_array(global.marker_caption_presets) || array_length(global.marker_caption_presets) == 0) {
        global.marker_caption_presets = [
            "Continue?",
            "Talk to the stranger?",
            "Help the traveler?",
            "Accept the quest?",
            "Leave them alone?"
        ];
    }
	    // Marker default template (safety)
    if (!variable_global_exists("marker_default") || is_undefined(global.marker_default) || !is_struct(global.marker_default))
    {
        global.marker_default = {
            type: "pause",
            snd_name: "snd_pause",
            fade_out_ms: 150,
            fade_in_ms: 150,
            wait_confirm: true,
            loop: true,
            caption: "Continue?",
            choices: []
        };
    }

	// ============================================================
	// F3: Toggle editor debug overlay (place ABOVE any early returns)
	// ============================================================
	if (!variable_global_exists("dbg_editor")) global.dbg_editor = false;


	// Master debug panel scrolling (F3 panel): wheel + thumb drag + PgUp/PgDn
	if (global.dbg_marker_keys_on)
	{
	    var gw_dbg = display_get_gui_width();
	    var gh_dbg = display_get_gui_height();
	    var margin_dbg = 16;
	    var px_dbg = margin_dbg;
	    var pw_dbg = gw_dbg - margin_dbg * 2;
	    var py_dbg = 200;
	    var ph_dbg = min(700, gh_dbg - py_dbg - margin_dbg);

	    var panel_pad_dbg = 10;
	    var header_h_dbg = 28;
	    var view_top_dbg = py_dbg + header_h_dbg;
	    var view_h_dbg = max(1, ph_dbg - header_h_dbg - panel_pad_dbg);

	    // Tweakables: line height, text paddings, scrollbar sizes, wheel speed.
	    var line_h_dbg = 18;
	    var text_top_pad_dbg = 6;
	    var text_bottom_pad_dbg = 10;
	    var scroll_speed_dbg = line_h_dbg * 3;
	    var scrollbar_pad_dbg = 10;
	    var scrollbar_w_dbg = 12;
	    var min_thumb_dbg = 28;

	    var left_lines_dbg = string_count("\n", global.dbg_marker_txtL) + 1;
	    var right_lines_dbg = string_count("\n", global.dbg_marker_txtR) + 1;
	    var line_count_dbg = max(left_lines_dbg, right_lines_dbg);
	    var content_h_dbg = text_top_pad_dbg + (line_count_dbg * line_h_dbg) + text_bottom_pad_dbg;
	    var max_scroll_dbg = max(0, content_h_dbg - view_h_dbg);

	    var track_x_dbg = px_dbg + pw_dbg - scrollbar_pad_dbg - scrollbar_w_dbg;
	    var track_y_dbg = view_top_dbg;
	    var track_h_dbg = view_h_dbg;
	    var thumb_h_dbg = max(min_thumb_dbg, track_h_dbg * (view_h_dbg / max(1, content_h_dbg)));
	    thumb_h_dbg = min(track_h_dbg, thumb_h_dbg);
	    var thumb_move_dbg = max(1, track_h_dbg - thumb_h_dbg);

	    global.dbg_marker_content_h = content_h_dbg;
	    global.dbg_marker_view_h = view_h_dbg;
	    global.dbg_marker_track_y = track_y_dbg;
	    global.dbg_marker_track_h = track_h_dbg;
	    global.dbg_marker_thumb_h = thumb_h_dbg;

	    var mx_dbg = device_mouse_x_to_gui(0);
	    var my_dbg = device_mouse_y_to_gui(0);
	    var panel_hover_dbg = (mx_dbg >= px_dbg && mx_dbg <= px_dbg + pw_dbg && my_dbg >= py_dbg && my_dbg <= py_dbg + ph_dbg);
	    if (panel_hover_dbg || global.dbg_marker_keys_on)
	    {
	        if (mouse_wheel_up()) global.dbg_marker_scroll_y -= scroll_speed_dbg;
	        if (mouse_wheel_down()) global.dbg_marker_scroll_y += scroll_speed_dbg;
	    }

	    if (keyboard_check_pressed(vk_pageup)) global.dbg_marker_scroll_y -= view_h_dbg * 0.9;
	    if (keyboard_check_pressed(vk_pagedown)) global.dbg_marker_scroll_y += view_h_dbg * 0.9;

	    var thumb_y_dbg = track_y_dbg;
	    if (max_scroll_dbg > 0) {
	        thumb_y_dbg = track_y_dbg + ((global.dbg_marker_scroll_y / max_scroll_dbg) * thumb_move_dbg);
	    }

	    var over_thumb_dbg = (mx_dbg >= track_x_dbg && mx_dbg <= track_x_dbg + scrollbar_w_dbg && my_dbg >= thumb_y_dbg && my_dbg <= thumb_y_dbg + thumb_h_dbg);
	    if (mouse_check_button_pressed(mb_left) && over_thumb_dbg && max_scroll_dbg > 0)
	    {
	        global.dbg_marker_dragging_thumb = true;
	        global.dbg_marker_drag_offset = my_dbg - thumb_y_dbg;
	    }
	    if (mouse_check_button_released(mb_left)) global.dbg_marker_dragging_thumb = false;

	    if (global.dbg_marker_dragging_thumb)
	    {
	        var new_thumb_y_dbg = clamp(my_dbg - global.dbg_marker_drag_offset, track_y_dbg, track_y_dbg + track_h_dbg - thumb_h_dbg);
	        var thumb_norm_dbg = (new_thumb_y_dbg - track_y_dbg) / thumb_move_dbg;
	        global.dbg_marker_scroll_y = thumb_norm_dbg * max_scroll_dbg;
	    }

	    global.dbg_marker_scroll_y = clamp(global.dbg_marker_scroll_y, 0, max_scroll_dbg);
	}
	else
	{
	    global.dbg_marker_dragging_thumb = false;
	    global.dbg_marker_scroll_y = 0;
	}

    // Debug vars for marker preset cycling (so you can draw them in GUI later if you want)
    if (!variable_global_exists("dbg_marker_preset_i")) global.dbg_marker_preset_i = -1;
    if (!variable_global_exists("dbg_marker_preset"))   global.dbg_marker_preset   = "";

    // Wipe marker file (Ctrl+Shift+M)
    // NOTE: This should stay at top so it doesn't conflict with marker-tool toggle on M
    if (keyboard_check(vk_control) && keyboard_check(vk_shift) && keyboard_check_pressed(ord("M"))) {
        scr_markers_wipe_file();
    }

    // ----------------------------
    // Toggle editor on/off
    // ----------------------------
    if (keyboard_check_pressed(global.editor_toggle_key)) {
        global.editor_on = !global.editor_on;

        if (global.editor_on) {
            // Enter editor
            if (global.song_handle >= 0) audio_pause_sound(global.song_handle);
        } else {
            // Exit editor
            scr_chart_sort();
            scr_markers_sort();
            scr_story_events_from_markers();
			if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
            if (global.song_handle >= 0) audio_stop_sound(global.song_handle);
            scr_song_play_from(global.editor_time);
			return;
        }
    }

    // If editor isn't on, stop here (nothing else should run)
    if (!global.editor_on) return;

    // ----------------------------
	// Ensure mode vars exist
	// ----------------------------
	if (!variable_global_exists("editor_act"))   global.editor_act = global.ACT_ATK1;
	if (!variable_global_exists("editor_act_i")) global.editor_act_i = 0;

	// ----------------------------
	// Ensure drag/marquee globals exist (prevents "not set before reading")
	// ----------------------------
	if (!variable_global_exists("drag_mode") || is_undefined(global.drag_mode)) {
	    global.drag_mode = "none";
	}

	if (!variable_global_exists("drag_marquee") || is_undefined(global.drag_marquee) || !is_struct(global.drag_marquee)) {
	    global.drag_marquee = {
	        active : false,
	        a_gui_x : 0,
	        a_gui_y : 0,
	        b_gui_x : 0,
	        b_gui_y : 0
	    };
	} else {
	    // If the struct exists but fields got lost, rebuild missing fields safely
	    if (!variable_struct_exists(global.drag_marquee, "active")) global.drag_marquee.active = false;
	    if (!variable_struct_exists(global.drag_marquee, "a_gui_x")) global.drag_marquee.a_gui_x = 0;
	    if (!variable_struct_exists(global.drag_marquee, "a_gui_y")) global.drag_marquee.a_gui_y = 0;
	    if (!variable_struct_exists(global.drag_marquee, "b_gui_x")) global.drag_marquee.b_gui_x = 0;
	    if (!variable_struct_exists(global.drag_marquee, "b_gui_y")) global.drag_marquee.b_gui_y = 0;
	}


    // ----------------------------
    // ACTION MODE HOTKEYS (SHIFT + 1–5)
    // ----------------------------
    var sh = keyboard_check(vk_shift);

	// Notes no longer support JUMP/DUCK actions.
	// SHIFT+1..4 selects which NOTE action you place.
	if (sh && keyboard_check_pressed(ord("1"))) { global.editor_act = global.ACT_ATK1; global.editor_act_i = 0; }
	if (sh && keyboard_check_pressed(ord("2"))) { global.editor_act = global.ACT_ATK2; global.editor_act_i = 1; }
	if (sh && keyboard_check_pressed(ord("3"))) { global.editor_act = global.ACT_ATK3; global.editor_act_i = 2; }
	if (sh && keyboard_check_pressed(ord("4"))) { global.editor_act = global.ACT_ULT;  global.editor_act_i = 3; }

    // ----------------------------
    // Tool toggles
    // ----------------------------
    // Phrase tool toggle (Y)
    if (keyboard_check_pressed(ord("Y"))) {
        global.editor_tool = (global.editor_tool == "phrase") ? "tap" : "phrase";
    }

    // Marker tool toggle (M)
    if (keyboard_check_pressed(ord("M"))) {
        global.editor_tool = (global.editor_tool == "marker") ? "tap" : "marker";
    }

    // ----------------------------
    // Marker tool editing (timeline story pause markers)
    // ----------------------------
    if (global.editor_tool == "marker")
    {
        if (keyboard_check_pressed(ord("Z"))) {
            global.editor_marker_place_i = (global.editor_marker_place_i - 1 + array_length(global.editor_marker_place_types)) mod array_length(global.editor_marker_place_types);
        }
        if (keyboard_check_pressed(ord("X"))) {
            global.editor_marker_place_i = (global.editor_marker_place_i + 1) mod array_length(global.editor_marker_place_types);
        }

        // Save/Load markers
        if (keyboard_check(vk_control) && keyboard_check_pressed(ord("S"))) scr_markers_save();
        if (keyboard_check(vk_control) && keyboard_check_pressed(ord("L"))) {
            scr_markers_load();
			scr_story_events_from_markers();
			if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
        }

        var mx_gui = device_mouse_x_to_gui(0);
        var my_gui = device_mouse_y_to_gui(0);

        // Delete selected
        if ((keyboard_check_pressed(vk_delete) || keyboard_check_pressed(vk_backspace)) &&
            global.editor_marker_sel >= 0 && global.editor_marker_sel < array_length(global.markers))
        {
            array_delete(global.markers, global.editor_marker_sel, 1);
            global.editor_marker_sel = -1;
            scr_story_events_from_markers();
			if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
			return;
        }

        // Right click deletes marker under mouse
        if (mouse_check_button_pressed(mb_right)) {
            var hit = scr_editor_marker_pick(mx_gui, my_gui);
            if (hit >= 0) {
                array_delete(global.markers, hit, 1);
                if (global.editor_marker_sel == hit) global.editor_marker_sel = -1;
                scr_story_events_from_markers();
				if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
                return;
            }
        }

        // Left click: select or create
        if (mouse_check_button_pressed(mb_left))
        {
            var pick = scr_editor_marker_pick(mx_gui, my_gui);

            if (pick >= 0) {
                global.editor_marker_sel = pick;

                // start drag
                var now_time = scr_chart_time();
                var pps_val = scr_timeline_pps();
                var gx = global.HIT_X_GUI + (global.markers[pick].t - now_time) * pps_val;
                global.editor_marker_drag = true;
                global.editor_marker_drag_dx = gx - mx_gui;
            }
            else
            {
                                // Place new marker at current time
                var place_t = scr_chart_time();
                if (global.editor_snap_on) place_t = scr_snap_time_to_tick(place_t);

				var place_type = global.editor_marker_place_types[global.editor_marker_place_i];

				// Existing modifier shortcuts still work and override palette selection.
				if (keyboard_check(vk_shift) && !keyboard_check(vk_alt)) place_type = "spawn";
				if (keyboard_check(vk_shift) && keyboard_check(vk_alt)) place_type = "pickup";
				if (keyboard_check(vk_alt) && !keyboard_check(vk_shift)) place_type = "camera";

				var m;

				if (place_type == "pickup")
				{
				    m = {
				        t: place_t,
				        type: "pickup",
				        pickup_kind: "shard",
				        y_gui: my_gui
				    };
				}
				else if (place_type == "camera")
				{
				    m = {
				        t: place_t,
				        type: "camera",
				        zoom: 1.0,
				        pan_x: 0,
				        pan_y: 0,
				        ease: "smooth",
				        caption: "CAM: z1.00 x0 y0"
				    };
				}
				else if (place_type == "spawn")
				{
				    m = {
				        t: place_t,
				        type: "spawn",
				        enemy_kind: "poptart",
				        lane: 0,
				        y_gui: my_gui
				    };
				}
				else if (place_type == "room_goto")
				{
				    m = {
				        t: place_t,
				        type: "room_goto",
				        kind: "room_goto",
				        side_idx: 0,
				        one_shot: true,
				        consumed: false,
				        caption: ""
				    };
				    if (script_exists(scr_marker_room_goto_set_idx)) {
				        scr_marker_room_goto_set_idx(m, m.side_idx);
				    }
				}
				else if (place_type == "difficulty")
				{
				    m = {
				        t: place_t,
				        type: "difficulty",
				        diff: "normal",
				        swap: "both",
				        caption: "DIFFICULTY: normal"
				    };
				}
				else
				{
				    m = {
				        t: place_t,
				        type: global.marker_default.type,
				        snd_name: global.marker_default.snd_name,
				        fade_out_ms: global.marker_default.fade_out_ms,
				        fade_in_ms: global.marker_default.fade_in_ms,
				        wait_confirm: global.marker_default.wait_confirm,
				        loop: global.marker_default.loop,
				        caption: global.marker_default.caption,
				        choices: global.marker_default.choices,
				        diff: "normal",
				        swap: "both"
				    };
				}


                array_push(global.markers, m);
                scr_markers_sort();


                // select the newly added marker (by nearest time match)
                var best = -1;
                var best_dt = 999999;
                for (var i = 0; i < array_length(global.markers); i++) {
                    var dt = abs(global.markers[i].t - place_t);
                    if (dt < best_dt) { best_dt = dt; best = i; }
                }
                global.editor_marker_sel = best;
				scr_story_events_from_markers();
				if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
            }

            // Don’t allow note placement logic below
            return;
        }

        // Dragging selected marker
        if (mouse_check_button(mb_left) && global.editor_marker_drag &&
            global.editor_marker_sel >= 0 && global.editor_marker_sel < array_length(global.markers))
        {
            var mdrag = global.markers[global.editor_marker_sel];
            var mdrag_type = variable_struct_exists(mdrag, "type") ? string(mdrag.type) : "";

            // Shift-drag spawn marker to move Y instead of timeline time.
            if (mdrag_type == "spawn" && keyboard_check(vk_shift))
            {
                mdrag.y_gui = clamp(my_gui, 40, display_get_gui_height() - 140);
                global.markers[global.editor_marker_sel] = mdrag;
            }
            else
            {
                var now_time2 = scr_chart_time();
                var pps2 = scr_timeline_pps();

                // Convert mouse X back into time
                var target_gx = mx_gui + global.editor_marker_drag_dx;
                var target_t = now_time2 + (target_gx - global.HIT_X_GUI) / pps2;

                if (global.editor_snap_on) target_t = scr_snap_time_to_tick(target_t);

                global.markers[global.editor_marker_sel].t = max(0, target_t);
            }

            scr_markers_sort();
            scr_story_events_from_markers();
			if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
        }

        if (mouse_check_button_released(mb_left)) {
            global.editor_marker_drag = false;
        }

        // Edit selected marker settings with keys
       if (global.editor_marker_sel >= 0 && global.editor_marker_sel < array_length(global.markers))
{
    var mm = global.markers[global.editor_marker_sel];
    if (!is_struct(mm)) return;

    var mm_type = (variable_struct_exists(mm, "type") ? string(mm.type) : "");


	// ----------------------------------------------------
	// SPAWN MARKER (ENEMY) EDIT MODE
	// ----------------------------------------------------
	if (mm_type == "spawn")
	{
	    if (!variable_struct_exists(mm, "enemy_kind")) mm.enemy_kind = "poptart";
	    if (!variable_struct_exists(mm, "y_gui"))      mm.y_gui = my_gui;

	    // G cycles enemy kind
	    if (keyboard_check_pressed(ord("G")))
	    {
	        if (script_exists(scr_enemy_kind_next)) mm.enemy_kind = scr_enemy_kind_next(mm.enemy_kind, 1);
	    }

	    // Shift + drag lets you move enemy spawn on Y axis
	    if (keyboard_check(vk_shift) && mouse_check_button(mb_left))
	    {
	        mm.y_gui = my_gui;
	    }

	    // Up/Down nudges Y for fine-tune
	    if (keyboard_check(vk_up))   mm.y_gui -= 4;
	    if (keyboard_check(vk_down)) mm.y_gui += 4;

	    mm.y_gui = clamp(mm.y_gui, 40, display_get_gui_height() - 140);
	    global.markers[global.editor_marker_sel] = mm;
	    exit;
	}

	// ----------------------------------------------------
	// PICKUP MARKER EDIT MODE
	// ----------------------------------------------------
	if (mm_type == "pickup")
	{
	    if (!variable_struct_exists(mm, "pickup_kind")) mm.pickup_kind = "shard";
	    if (!variable_struct_exists(mm, "y_gui"))       mm.y_gui = mouse_y;

	    // J cycles pickup kind (chart/eyes/shard)
	    if (keyboard_check_pressed(ord("J")))
	        mm.pickup_kind = scr_pickup_kind_next(mm.pickup_kind, 1);

	    // Up/Down nudges Y
	    if (keyboard_check(vk_up))   mm.y_gui -= 4;
	    if (keyboard_check(vk_down)) mm.y_gui += 4;

	    // Shift sets y to mouse (hold)
	    if (keyboard_check(vk_shift) && mouse_check_button(mb_left))
	        mm.y_gui = my_gui;

	    // Clamp into GUI
	    mm.y_gui = clamp(mm.y_gui, 40, display_get_gui_height() - 140);

	    global.markers[global.editor_marker_sel] = mm;
	    exit;
	}


	// ----------------------------------------------------
	// CAMERA MARKER EDIT MODE
	// ----------------------------------------------------
	if (mm_type == "camera")
	{
	    if (!variable_struct_exists(mm, "zoom")) mm.zoom = 1.0;
	    if (!variable_struct_exists(mm, "pan_x")) mm.pan_x = 0;
	    if (!variable_struct_exists(mm, "pan_y")) mm.pan_y = 0;
	    if (!variable_struct_exists(mm, "ease")) mm.ease = "smooth";

	    var changed_cam = false;
	    var pan_step = keyboard_check(vk_shift) ? 16 : 4;

	    if (keyboard_check(vk_left))  { mm.pan_x -= pan_step; changed_cam = true; }
	    if (keyboard_check(vk_right)) { mm.pan_x += pan_step; changed_cam = true; }
	    if (keyboard_check(vk_up))    { mm.pan_y -= pan_step; changed_cam = true; }
	    if (keyboard_check(vk_down))  { mm.pan_y += pan_step; changed_cam = true; }

	    if (keyboard_check_pressed(ord("Q"))) { mm.zoom -= 0.02; changed_cam = true; }
	    if (keyboard_check_pressed(ord("E"))) { mm.zoom += 0.02; changed_cam = true; }

	    if (keyboard_check_pressed(ord("R")))
	    {
	        mm.zoom = 1.0;
	        mm.pan_x = 0;
	        mm.pan_y = 0;
	        changed_cam = true;
	    }

	    if (keyboard_check_pressed(ord("C")) || keyboard_check_pressed(ord("V")))
	    {
	        var ease_modes = ["smooth", "linear", "hold"];
	        var ease_i = 0;
	        for (var ci = 0; ci < array_length(ease_modes); ci++) {
	            if (ease_modes[ci] == string_lower(string(mm.ease))) { ease_i = ci; break; }
	        }

	        if (keyboard_check_pressed(ord("C"))) ease_i = (ease_i - 1 + array_length(ease_modes)) mod array_length(ease_modes);
	        else ease_i = (ease_i + 1) mod array_length(ease_modes);

	        mm.ease = ease_modes[ease_i];
	        changed_cam = true;
	    }

	    mm.zoom = clamp(real(mm.zoom), 0.35, 3.0);
	    mm.pan_x = clamp(real(mm.pan_x), -2500, 2500);
	    mm.pan_y = clamp(real(mm.pan_y), -1800, 1800);
	    mm.caption = "CAM: z" + string_format(mm.zoom, 1, 2) + " x" + string(round(mm.pan_x)) + " y" + string(round(mm.pan_y)) + " [" + string(mm.ease) + "]";

	    if (changed_cam)
	    {
	        global.markers[global.editor_marker_sel] = mm;
	        scr_story_events_from_markers();
	        if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
	    }

	    return;
	}

// ----------------------------------------------------
// DIFFICULTY MARKER EDIT MODE
// ----------------------------------------------------
if (mm_type == "difficulty" || mm_type == "diff")
{
    if (!variable_struct_exists(mm, "diff")) mm.diff = "normal";
    if (!variable_struct_exists(mm, "swap") || !is_string(mm.swap)) mm.swap = "both";

    var changed = false;

    // SHIFT + 7/8/9 OR NUMPAD 7/8/9 sets difficulty
    var k_easy   = (keyboard_check(vk_shift) && keyboard_check_pressed(ord("7"))) || keyboard_check_pressed(vk_numpad7);
    var k_normal = (keyboard_check(vk_shift) && keyboard_check_pressed(ord("8"))) || keyboard_check_pressed(vk_numpad8);
    var k_hard   = (keyboard_check(vk_shift) && keyboard_check_pressed(ord("9"))) || keyboard_check_pressed(vk_numpad9);

    if (k_easy)   { mm.diff = "easy";   mm.caption = "DIFFICULTY: easy";   show_debug_message("[DIFF MARKER] -> easy");   changed = true; }
    if (k_normal) { mm.diff = "normal"; mm.caption = "DIFFICULTY: normal"; show_debug_message("[DIFF MARKER] -> normal"); changed = true; }
    if (k_hard)   { mm.diff = "hard";   mm.caption = "DIFFICULTY: hard";   show_debug_message("[DIFF MARKER] -> hard");   changed = true; }

    // SHIFT + D cycles swap: both -> visual -> audio -> both
    if (keyboard_check(vk_shift) && keyboard_check_pressed(ord("D")))
    {
        var s = string_lower(string(mm.swap));
        if (s != "both" && s != "visual" && s != "audio") s = "both";

        if (s == "both") s = "visual";
        else if (s == "visual") s = "audio";
        else s = "both";

        mm.swap = s;
        show_debug_message("[DIFF MARKER] swap -> " + s);
        changed = true;
    }

    if (changed)
    {
        global.markers[global.editor_marker_sel] = mm;

        // Rebuild marker-driven systems
        scr_story_events_from_markers();
        if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
    }

    return;
}

// ----------------------------------------------------
// ROOM GOTO MARKER EDIT MODE
// ----------------------------------------------------
if (mm_type == "room_goto")
{
    if (!variable_struct_exists(mm, "side_idx")) mm.side_idx = 0;
    if (!variable_struct_exists(mm, "one_shot")) mm.one_shot = true;
    if (!variable_struct_exists(mm, "consumed")) mm.consumed = false;

    var idx = floor(real(mm.side_idx));
    if (keyboard_check_pressed(ord("Q"))) idx -= 1;
    if (keyboard_check_pressed(ord("E"))) idx += 1;

    if (script_exists(scr_marker_room_goto_set_idx)) {
        scr_marker_room_goto_set_idx(mm, idx);
    } else {
        mm.side_idx = idx;
        mm.caption = "GOTO " + string(mm.side_idx);
    }

    global.markers[global.editor_marker_sel] = mm;
    return;
}

    // ----------------------------------------------------
    // PAUSE/STORY MARKER EDIT MODE (safe defaults)
    // ----------------------------------------------------
    if (!variable_struct_exists(mm, "snd_name")) mm.snd_name = global.marker_default.snd_name;
    if (!variable_struct_exists(mm, "caption"))  mm.caption  = global.marker_default.caption;
    if (!variable_struct_exists(mm, "choices"))  mm.choices  = global.marker_default.choices;

			// Toggle marker to CAMERA (U)
			if (keyboard_check_pressed(ord("U")))
			{
			    mm.type = "camera";
			    mm.zoom = 1.0;
			    mm.pan_x = 0;
			    mm.pan_y = 0;
			    mm.ease = "smooth";
			    mm.caption = "CAM: z1.00 x0 y0";
			    mm.wait_confirm = false;
			    mm.loop = false;
			    mm.choices = [];

			    global.markers[global.editor_marker_sel] = mm;
			    scr_story_events_from_markers();
			    if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
			    exit;
			}

			// Toggle marker to DIFFICULTY (T)
			if (keyboard_check_pressed(ord("T")))
			{
			    mm.type = "difficulty";
			    mm.diff = "normal";
				mm.swap = "both";
			    mm.caption = "DIFFICULTY: normal";
			    mm.wait_confirm = false;
			    mm.loop = false;
			    mm.choices = [];
				

			    global.markers[global.editor_marker_sel] = mm;
			    scr_story_events_from_markers();
				if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
			    exit;
			}

			// Toggle marker to ROOM_GOTO (I)
			if (keyboard_check_pressed(ord("I")))
			{
			    mm.type = "room_goto";
			    mm.kind = "room_goto";
			    mm.side_idx = variable_struct_exists(mm, "side_idx") ? mm.side_idx : 0;
			    mm.one_shot = true;
			    mm.consumed = false;
			    mm.wait_confirm = false;
			    mm.loop = false;
			    mm.choices = [];

			    if (script_exists(scr_marker_room_goto_set_idx)) {
			        scr_marker_room_goto_set_idx(mm, mm.side_idx);
			    }

			    global.markers[global.editor_marker_sel] = mm;
			    scr_story_events_from_markers();
				if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
			    exit;
			}
            // Toggle Yes/No choices (N)
            if (keyboard_check_pressed(ord("N"))) {
                if (!is_array(mm.choices) || array_length(mm.choices) == 0) {
                    mm.caption = "Continue?";
                    mm.choices = ["Yes", "No"];
                } else {
                    mm.choices = [];
                }
                scr_story_events_from_markers();
				if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
            }

            // Toggle looping (R)
            if (keyboard_check_pressed(ord("R"))) {
                mm.loop = !mm.loop;
                scr_story_events_from_markers();
				if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
            }

            // Toggle wait confirm (F)
            if (keyboard_check_pressed(ord("F"))) {
                mm.wait_confirm = !mm.wait_confirm;
                scr_story_events_from_markers();
				if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
            }

            // Cycle caption presets (C / V)  <-- ADDED DEBUG HERE
            if (keyboard_check_pressed(ord("C")) || keyboard_check_pressed(ord("V"))) {
                var list = global.marker_caption_presets;
                var cur = 0;

                // find current index by matching caption
                for (var i = 0; i < array_length(list); i++) {
                    if (list[i] == mm.caption) { cur = i; break; }
                }

                if (keyboard_check_pressed(ord("C"))) {
                    cur = cur - 1;
                    if (cur < 0) cur = array_length(list) - 1;
                } else {
                    cur = (cur + 1) mod array_length(list);
                }

                mm.caption = list[cur];

                // DEBUG: show which dialogue preset you’re on
                global.dbg_marker_preset_i = cur;
                global.dbg_marker_preset   = mm.caption;
                show_debug_message("[MARKER PRESET] i=" + string(cur) + " / " + string(array_length(list) - 1) + " :: " + mm.caption);

                scr_story_events_from_markers();
				if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
            }

            // Fade out adjust (O/P)
            if (keyboard_check_pressed(ord("O"))) { mm.fade_out_ms = max(0, mm.fade_out_ms - 50); scr_story_events_from_markers(); }
            if (keyboard_check_pressed(ord("P"))) { mm.fade_out_ms = mm.fade_out_ms + 50;          scr_story_events_from_markers(); }

            // Fade in adjust (K/L)
            if (keyboard_check_pressed(ord("K"))) { mm.fade_in_ms = max(0, mm.fade_in_ms - 50); scr_story_events_from_markers(); }
            if (keyboard_check_pressed(ord("L"))) { mm.fade_in_ms = mm.fade_in_ms + 50;          scr_story_events_from_markers(); }

            // Cycle sound name (Q/E)
            if (array_length(global.marker_sound_list) > 0)
            {
                // find current index
                var cur_s = 0;
                for (var si = 0; si < array_length(global.marker_sound_list); si++) {
                    if (global.marker_sound_list[si] == mm.snd_name) { cur_s = si; break; }
                }

                if (keyboard_check_pressed(ord("Q"))) {
                    cur_s = cur_s - 1;
                    if (cur_s < 0) cur_s = array_length(global.marker_sound_list) - 1;
                    mm.snd_name = global.marker_sound_list[cur_s];
                    scr_story_events_from_markers();
					if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
                }

                if (keyboard_check_pressed(ord("E"))) {
                    cur_s = (cur_s + 1) mod array_length(global.marker_sound_list);
                    mm.snd_name = global.marker_sound_list[cur_s];
                    scr_story_events_from_markers();
					if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
                }
            }

            // IMPORTANT: write back marker edits every frame we touch mm
            global.markers[global.editor_marker_sel] = mm;
        }

        // Marker tool should not run note placement/dragging below
        return;
    }
	
    // ----------------------------
    // Timeline Zoom Controls
    // ----------------------------
    if (keyboard_check_pressed(ord("["))) global.timeline_zoom *= 0.90;
    if (keyboard_check_pressed(ord("]"))) global.timeline_zoom *= 1.10;

    if (keyboard_check(vk_control)) {
        var wheel_delta_zoom = (mouse_wheel_up ? 1 : 0) - (mouse_wheel_down ? 1 : 0);
        if (wheel_delta_zoom != 0) {
            if (wheel_delta_zoom > 0) global.timeline_zoom *= 1.10;
            else global.timeline_zoom *= 0.90;
        }
    }

    if (keyboard_check_pressed(ord("\\"))) {
    if (!variable_global_exists("timeline_zoom_default")) global.timeline_zoom_default = 0.54;
    global.timeline_zoom = global.timeline_zoom_default;
}

    // ----------------------------
    // Snap toggle + snap amount
    // ----------------------------
    if (keyboard_check_pressed(global.editor_snap_key)) {
        global.editor_snap_on = !global.editor_snap_on;
    }

    if (keyboard_check_pressed(ord(","))) {
        global.editor_snap_index = max(0, global.editor_snap_index - 1);
        global.editor_snap = global.editor_snap_options[global.editor_snap_index];
    }

    if (keyboard_check_pressed(ord("."))) {
        global.editor_snap_index = min(array_length(global.editor_snap_options)-1, global.editor_snap_index + 1);
        global.editor_snap = global.editor_snap_options[global.editor_snap_index];
    }

    // ----------------------------
    // Tool toggle: H (tap/hold)
    // ----------------------------
    if (keyboard_check_pressed(ord("H"))) {
        if (global.editor_tool == "tap") global.editor_tool = "hold";
        else if (global.editor_tool == "hold") global.editor_tool = "tap";
    }

    // ----------------------------
    // Scrub time (arrow keys + wheel)
    // ----------------------------
    var step = 0.25;
    if (keyboard_check(vk_shift))   step = 1.0;
    if (keyboard_check(vk_control)) step = 0.05;

    if (global.editor_tool != "phrase") {
        if (keyboard_check(vk_left))  global.editor_time = max(0, global.editor_time - step);
        if (keyboard_check(vk_right)) global.editor_time = global.editor_time + step;
    }

    var wheel_delta_time = mouse_wheel_up() - mouse_wheel_down();
    if (wheel_delta_time != 0) global.editor_time = max(0, global.editor_time + wheel_delta_time * step);

    if (global.editor_snap_on) {
        var t = global.editor_time;
        t = scr_editor_snap_time(t);
        global.editor_time = t;
    }

    // ----------------------------
    // Mouse GUI coords
    // ----------------------------
    var mx_gui = device_mouse_x_to_gui(0);
    var my_gui = device_mouse_y_to_gui(0);

    // ----------------------------
    // CLEAR ALL NOTES: CTRL+SHIFT+X
    // ----------------------------
    if (!variable_global_exists("_clear_combo_prev")) global._clear_combo_prev = false;

    var combo_now = keyboard_check(vk_control) && keyboard_check(vk_shift) && keyboard_check(ord("X"));
    if (combo_now && !global._clear_combo_prev) scr_chart_clear();
    global._clear_combo_prev = combo_now;

    // ----------------------------
	// Save / Load chart
	// ----------------------------

		// CTRL + S = Save CURRENT chart_file (boss/easy/normal/hard — whatever is loaded)
		if (keyboard_check(vk_control) && keyboard_check_pressed(ord("S"))) {
		    // Make sure chart_file exists
		    if (variable_global_exists("chart_file") && global.chart_file != "") {
		        scr_chart_save();
		        scr_chart_load(); // optional, but matches your "save+reload" workflow
		        show_debug_message("[chart] Saved current: " + string(global.chart_file));
		    } else {
		        show_debug_message("[chart] ERROR: global.chart_file not set");
		    }
		}

		// CTRL + L = Reload CURRENT chart_file
		if (keyboard_check(vk_control) && keyboard_check_pressed(ord("L"))) {
		    if (variable_global_exists("chart_file") && global.chart_file != "") {
		        scr_chart_load();
		        show_debug_message("[chart] Reloaded: " + string(global.chart_file));
		    }
		}

		// CTRL + 1 / 2 / 3 switch difficulty (these explicitly switch files)
		if (keyboard_check(vk_control) && keyboard_check_pressed(ord("1"))) {
		    scr_chart_save_and_reload("level01_easy.json");
		}
		if (keyboard_check(vk_control) && keyboard_check_pressed(ord("2"))) {
		    scr_chart_save_and_reload("charts/level03/normal_v2.json");
		}
		if (keyboard_check(vk_control) && keyboard_check_pressed(ord("3"))) {
		    scr_chart_save_and_reload("charts/level03/hard_v2.json");
		}
		// CTRL + 4 = Boss chart
		if (keyboard_check(vk_control) && keyboard_check_pressed(ord("4"))) {
		    scr_chart_save_and_reload(global.BOSS_CHART_FILE);
		    show_debug_message("[chart] Switched to BOSS: " + string(global.chart_file));
		}



    // ----------------------------
    // Phrase step editing (only while in phrase tool)
    // ----------------------------
    if (global.editor_tool == "phrase") {

        if (keyboard_check_pressed(ord("P"))) {
            var place_t = scr_chart_time();
            if (global.editor_snap_on) place_t = scr_snap_time_to_tick(place_t);
            scr_phrase_add_default(place_t);
            global.editor_phrase_sel = array_length(global.phrases) - 1;
            global.editor_phrase_step_sel = 0;
        }

        if (mouse_check_button_pressed(mb_left)) {
            var pick = scr_editor_phrase_pick(mx_gui, my_gui);
            if (pick >= 0) global.editor_phrase_sel = pick;
        }

        if (global.editor_phrase_sel >= 0 && global.editor_phrase_sel < array_length(global.phrases)) {
            var ph = global.phrases[global.editor_phrase_sel];
            var tick_s = global.SEC_PER_BEAT / global.TICKS_PER_BEAT;

            if (keyboard_check_pressed(vk_left))  ph.steps[global.editor_phrase_step_sel].dt -= tick_s;
            if (keyboard_check_pressed(vk_right)) ph.steps[global.editor_phrase_step_sel].dt += tick_s;

            if (ph.steps[global.editor_phrase_step_sel].dt < 0) ph.steps[global.editor_phrase_step_sel].dt = 0;

            if (keyboard_check_pressed(ord("N"))) {
                var last_dt = 0.0;
                if (array_length(ph.steps) > 0) last_dt = ph.steps[array_length(ph.steps)-1].dt;
                array_push(ph.steps, { dt: last_dt + tick_s, b: 1 });
                global.editor_phrase_step_sel = array_length(ph.steps)-1;
            }

            if (keyboard_check_pressed(vk_backspace)) {
                if (array_length(ph.steps) > 0) {
                    array_delete(ph.steps, global.editor_phrase_step_sel, 1);
                    global.editor_phrase_step_sel = clamp(global.editor_phrase_step_sel, 0, array_length(ph.steps)-1);
                }
            }

            if (keyboard_check(vk_control) && keyboard_check_pressed(ord("S"))) scr_phrases_save();
            if (keyboard_check(vk_control) && keyboard_check_pressed(ord("L"))) scr_phrases_load();
        }

        return;
    }

// ----------------------------
    // Copy / Paste / Duplicate (preserve ACT)
    // ----------------------------
    if (keyboard_check(vk_control) && keyboard_check_pressed(ord("C"))) {
        global.clipboard = [];
        if (array_length(global.sel) > 0) {
            var min_t = 999999;
            for (var i = 0; i < array_length(global.sel); i++) {
                var idx = global.sel[i];
                if (idx < 0 || idx >= array_length(global.chart)) continue;
                min_t = min(min_t, global.chart[idx].t);
            }

            for (var j = 0; j < array_length(global.sel); j++) {
                var id2 = global.sel[j];
                if (id2 < 0 || id2 >= array_length(global.chart)) continue;

                var nref = global.chart[id2];
                var copy_act = variable_struct_exists(nref, "act") ? nref.act : global.editor_act;

                var copy_n = { t: nref.t - min_t, lane: nref.lane, type: nref.type, act: copy_act };
                if (nref.type == "hold") copy_n.dur = nref.dur;

                array_push(global.clipboard, copy_n);
            }
        }
    }

    if (keyboard_check(vk_control) && keyboard_check_pressed(ord("V"))) {
        var paste_t = scr_chart_time();
        if (global.editor_snap_on) paste_t = scr_snap_time_to_tick(paste_t);

        if (array_length(global.clipboard) > 0) {
            scr_editor_selection_clear();
            for (var c = 0; c < array_length(global.clipboard); c++) {
                var cn = global.clipboard[c];
                var new_n = { t: paste_t + cn.t, lane: cn.lane, type: cn.type, act: cn.act };
                if (cn.type == "hold") new_n.dur = cn.dur;
                array_push(global.chart, new_n);
                scr_editor_selection_add(array_length(global.chart)-1);
            }
        }
    }

    if (keyboard_check(vk_control) && keyboard_check_pressed(ord("D"))) {
        if (array_length(global.sel) > 0) {
            var dt = global.editor_snap * global.SEC_PER_BEAT;
            var to_add = [];

            for (var s = 0; s < array_length(global.sel); s++) {
                var idxd = global.sel[s];
                if (idxd < 0 || idxd >= array_length(global.chart)) continue;

                var n0 = global.chart[idxd];
                var a0 = variable_struct_exists(n0, "act") ? n0.act : global.editor_act;

                var n1 = { t: n0.t + dt, lane: n0.lane, type: n0.type, act: a0 };
                if (n0.type == "hold") n1.dur = n0.dur;

                array_push(to_add, n1);
            }

            scr_editor_selection_clear();
            for (var a = 0; a < array_length(to_add); a++) {
                array_push(global.chart, to_add[a]);
                scr_editor_selection_add(array_length(global.chart)-1);
            }
        }
    }
// ----------------------------
// DELETE SELECTED NOTES: Delete / Backspace
// ----------------------------
if (keyboard_check_pressed(vk_delete) || keyboard_check_pressed(vk_backspace))
{
    var sel_len = array_length(global.sel);

    if (sel_len > 0)
    {
        // Copy selection indices manually (no array_copy)
        var idxs = [];
        for (var i = 0; i < sel_len; i++) {
            idxs[i] = global.sel[i];
        }

        // Sort descending so array_delete doesn't shift upcoming indices
        var n = array_length(idxs);
        for (var a = 0; a < n - 1; a++) {
            for (var b = a + 1; b < n; b++) {
                if (idxs[a] < idxs[b]) {
                    var tmp = idxs[a];
                    idxs[a] = idxs[b];
                    idxs[b] = tmp;
                }
            }
        }

        // Delete (skip duplicates/invalid)
        var last = -999999;
        for (var k = 0; k < n; k++)
        {
            var idx = idxs[k];
            if (idx == last) continue;
            last = idx;

            if (idx >= 0 && idx < array_length(global.chart)) {
                array_delete(global.chart, idx, 1);
            }
        }

        // Clear selection after deletion
        scr_editor_selection_clear();
    }
}



    // ----------------------------
    // Mouse down logic (select / drag / marquee)
    // ----------------------------
    if (mouse_check_button_pressed(mb_left)) {
        var now_time = scr_chart_time();

        // Hold end pick
        var end_hit = scr_editor_find_hold_end_at(mx_gui, my_gui, now_time, 22);
        if (end_hit >= 0) {
            global.drag_mode = "end";
            global.drag_end_index = end_hit;

            if (!keyboard_check(vk_shift) && !scr_editor_selection_has(end_hit)) {
                scr_editor_selection_clear();
            }
            scr_editor_selection_add(end_hit);
            return;
        }

        // Note head pick
        var head_hit = scr_editor_find_note_at(mx_gui, my_gui, now_time, 22);
        if (head_hit >= 0) {
            global.drag_mode = "note";
            global.drag_note_index = head_hit;

            if (keyboard_check(vk_shift)) {
                if (scr_editor_selection_has(head_hit)) scr_editor_selection_remove(head_hit);
                else scr_editor_selection_add(head_hit);
            } else {
                if (!scr_editor_selection_has(head_hit)) {
                    scr_editor_selection_clear();
                    scr_editor_selection_add(head_hit);
                }
            }

            global.drag_mouse_start_t = now_time;
            global.drag_start_times = [];
            global.drag_start_y = [];


            for (var s0 = 0; s0 < array_length(global.sel); s0++) {
                var id0 = global.sel[s0];
                if (id0 < 0 || id0 >= array_length(global.chart)) continue;
                array_push(global.drag_start_times, global.chart[id0].t);
                var y0 = (variable_struct_exists(global.chart[id0], "y_gui")
			    ? global.chart[id0].y_gui
			    : global.LANE_Y[clamp(floor(global.chart[id0].lane), 0, array_length(global.LANE_Y)-1)]);
			array_push(global.drag_start_y, y0);

            }
            return;
        }

        // Start marquee
        global.drag_mode = "marquee";
        global.drag_marquee.active = true;
        global.drag_marquee.a_gui_x = mx_gui;
        global.drag_marquee.a_gui_y = my_gui;
        global.drag_marquee.b_gui_x = mx_gui;
        global.drag_marquee.b_gui_y = my_gui;

        if (!keyboard_check(vk_shift)) scr_editor_selection_clear();
    }

    // Update marquee while held
    if (mouse_check_button(mb_left) && global.drag_mode == "marquee") {
        global.drag_marquee.b_gui_x = mx_gui;
        global.drag_marquee.b_gui_y = my_gui;
    }

	// Drag notes while held
	if (mouse_check_button(mb_left) && global.drag_mode == "note") {
	    var now_time2 = scr_chart_time();
	    var pps = scr_timeline_pps() * global.timeline_zoom;
	    var target_t = now_time2 + (mx_gui - global.HIT_X_GUI) / pps;

	    if (global.editor_snap_on) target_t = scr_snap_time_to_tick(target_t);

	    // Notes are lane-free: drag sets per-note GUI Y directly (like enemies)
	    var target_y = clamp(my_gui, 0, display_get_gui_height());

	    // Find original t/y of the anchor note (the one you clicked)
	    var anchor_t = 0.0;
	    var anchor_y = target_y;

	    for (var si = 0; si < array_length(global.sel); si++) {
	        if (global.sel[si] == global.drag_note_index) {
	            anchor_t = global.drag_start_times[si];
	            anchor_y = global.drag_start_y[si];
	            break;
	        }
	    }

	    // Apply relative offsets to the whole selection
	    for (var s1 = 0; s1 < array_length(global.sel); s1++) {
	        var idx1 = global.sel[s1];
	        if (idx1 < 0 || idx1 >= array_length(global.chart)) continue;

	        var orig_t = global.drag_start_times[s1];
	        var dt2 = orig_t - anchor_t;

	        var orig_y = global.drag_start_y[s1];
	        var dy2 = orig_y - anchor_y;

	        global.chart[idx1].t = max(0, target_t + dt2);
	        global.chart[idx1].y_gui = clamp(target_y + dy2, 0, display_get_gui_height());
	        global.chart[idx1].lane = 0; // keep lane locked for compatibility
	    }
	}


    // Drag hold end while held
    if (mouse_check_button(mb_left) && global.drag_mode == "end") {
        var idxe = global.drag_end_index;
        if (idxe >= 0 && idxe < array_length(global.chart)) {
            var nend = global.chart[idxe];
            if (nend.type == "hold") {
                var now_time3 = scr_chart_time();
                var pps2 = scr_timeline_pps();
                var end_target_t = now_time3 + (mx_gui - global.HIT_X_GUI) / pps2;

                if (global.editor_snap_on) end_target_t = scr_snap_time_to_tick(end_target_t);

                var new_dur = max(0.0, end_target_t - nend.t);

                if (global.editor_snap_on) {
                    var beats_d = new_dur / global.SEC_PER_BEAT;
                    beats_d = round(beats_d / global.editor_snap) * global.editor_snap;
                    new_dur = max(0.0, beats_d * global.SEC_PER_BEAT);
                }

                nend.dur = new_dur;
            }
        }
    }

    // Mouse release
    if (mouse_check_button_released(mb_left)) {

        // Finalize marquee selection
        if (global.drag_mode == "marquee" && global.drag_marquee.active) {
            var ax = global.drag_marquee.a_gui_x;
            var ay = global.drag_marquee.a_gui_y;
            var bx = global.drag_marquee.b_gui_x;
            var by = global.drag_marquee.b_gui_y;

            var l = min(ax, bx);
            var r = max(ax, bx);
            var tbox = min(ay, by);
            var bbox = max(ay, by);

            var now_time4 = scr_chart_time();

            for (var i2 = 0; i2 < array_length(global.chart); i2++) {
                var nn = global.chart[i2];
                var p2 = scr_editor_note_gui_pos(nn, now_time4);

                if (p2.gx >= l && p2.gx <= r && p2.gy >= tbox && p2.gy <= bbox) {
                    scr_editor_selection_add(i2);
                }
            }
        }

        // Place note if it was a click (small drag)
        if (global.drag_mode == "marquee") {
            var dxm = abs(global.drag_marquee.b_gui_x - global.drag_marquee.a_gui_x);
            var dym = abs(global.drag_marquee.b_gui_y - global.drag_marquee.a_gui_y);

            if (dxm < 8 && dym < 8) {
                var place_lane = 0;
				var place_y = clamp(my_gui, 0, display_get_gui_height());

                var place_t = scr_chart_time();
                if (global.editor_snap_on) place_t = scr_snap_time_to_tick(place_t);

                if (global.editor_tool == "tap") {
                    array_push(global.chart, { t: place_t, lane: place_lane, y_gui: place_y, type: "tap", act: global.editor_act });
                } else {
                    var dsec = global.editor_hold_default_beats * global.SEC_PER_BEAT;

                    // snap duration to grid
                    if (global.editor_snap_on) {
                        var beats_d2 = dsec / global.SEC_PER_BEAT;
                        beats_d2 = round(beats_d2 / global.editor_snap) * global.editor_snap;
                        dsec = max(0.0, beats_d2 * global.SEC_PER_BEAT);
                    }

                    array_push(global.chart, { t: place_t, lane: place_lane, y_gui: place_y, type: "hold", dur: dsec, act: global.editor_act });
                }
			show_debug_message("[PLACE] editor_act=" + string(global.editor_act)
			    + " type=" + typeof(global.editor_act));
                scr_editor_selection_clear();
                scr_editor_selection_add(array_length(global.chart)-1);
            }
        }

        // Reset drag state
        global.drag_mode = "none";
        global.drag_note_index = -1;
        global.drag_end_index = -1;
        global.drag_marquee.active = false;
    }

    // Right-click delete note head near cursor
    if (mouse_check_button_pressed(mb_right)) {
        var now_time5 = scr_chart_time();
        var hit_i = scr_editor_find_note_at(mx_gui, my_gui, now_time5, 22);
        if (hit_i >= 0) {
            array_delete(global.chart, hit_i, 1);
            scr_editor_selection_clear();
        }
    }
}
