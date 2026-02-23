function scr_chart_load()
{
    // Always define chart so downstream code never crashes
    global.chart = [];
    global.dbg_last_chart_load_t = (script_exists(scr_song_time) ? scr_song_time() : -1);

    if (!variable_global_exists("chart_file")) {
        show_debug_message("[scr_chart_load] global.chart_file not set; skipping load.");
        return;
    }
    if (is_undefined(global.chart_file) || global.chart_file == "") {
        show_debug_message("[scr_chart_load] global.chart_file empty; skipping load.");
        return;
    }

    // ------------------------------------------------------------
    // Resolve path robustly:
    // 1) sandbox path as-given
    // 2) if only filename is provided, map via scr_chart_fullpath()
    // 3) included fallback: datafiles/ + chart_file
    // ------------------------------------------------------------
    var want = string(global.chart_file);

    var path = want;

    if (string_pos("/", path) == 0 && string_pos("\\", path) == 0)
    {
        path = scr_chart_fullpath(path);
    }

    if (!file_exists(path))
    {
        // Legacy fallbacks -> new authoritative naming
        if (want == "level03_normal_v2.json") path = scr_chart_fullpath(scr_chart_filename(3, "normal", false));
        else if (want == "level03_hard_v2.json") path = scr_chart_fullpath(scr_chart_filename(3, "hard", false));
    }

    // sandbox check
    if (!file_exists(path))
        path = "datafiles/" + string(path); // included fallback

    if (!file_exists(path))
    {
        show_debug_message("[scr_chart_load] Chart not found!");
        show_debug_message("  want=" + want);
        show_debug_message("  tried=" + path);
        show_debug_message("  working_directory=" + working_directory);
        global.chart = [];
        return;
    }

    // Remember what we loaded
    global.chart_loaded_path = path;
    global.chart_loaded_from_datafiles = (string_pos("datafiles/", path) == 1);

    // -------------------------------
    // Read JSON text
    // -------------------------------
    var fh = file_text_open_read(path);
    if (fh < 0) {
        show_debug_message("[scr_chart_load] Failed to open: " + string(path));
        return;
    }

    var json_txt = "";
    while (!file_text_eof(fh)) {
        json_txt += file_text_read_string(fh);
        file_text_readln(fh);
    }
    file_text_close(fh);

    json_txt = string_trim(json_txt);
    if (json_txt == "") {
        show_debug_message("[scr_chart_load] Empty chart file: " + string(path));
        return;
    }

    // -------------------------------
    // Parse JSON
    // -------------------------------
    var data = json_parse(json_txt);

    // Defaults (safe)
    if (!variable_global_exists("BPM")) global.BPM = 140;
    if (!variable_global_exists("SEC_PER_BEAT")) global.SEC_PER_BEAT = 60.0 / 140.0;

    // Per-chart metadata (safe defaults)
    if (!variable_global_exists("chart_bpm")) global.chart_bpm = global.BPM;
    if (!variable_global_exists("chart_offset")) global.chart_offset = 0.0;

    if (is_array(data)) {
        global.chart = data;
    }
    else if (is_struct(data))
    {
        if (variable_struct_exists(data, "notes") && is_array(data.notes)) {
            global.chart = data.notes;
        }
        else if (variable_struct_exists(data, "chart") && is_array(data.chart)) {
            global.chart = data.chart;
        }
        else {
            show_debug_message("[scr_chart_load] Unexpected JSON format in: " + string(path));
            global.chart = [];
            return;
        }

        // Read bpm/offset if present (your chart uses these) :contentReference[oaicite:1]{index=1}
        if (variable_struct_exists(data, "bpm") && is_real(data.bpm)) {
            global.BPM = data.bpm;
            global.chart_bpm = data.bpm;
        } else {
            global.chart_bpm = global.BPM;
        }

        if (variable_struct_exists(data, "offset") && is_real(data.offset)) {
            global.chart_offset = data.offset;
        } else {
            global.chart_offset = 0.0;
        }

        global.SEC_PER_BEAT = 60.0 / max(1.0, global.BPM);

        // Link existing timing offset hook if your project uses it elsewhere
        global.CHART_TIME_OFFSET_S = global.chart_offset;
    }
    else {
        show_debug_message("[scr_chart_load] Unexpected JSON format in: " + string(path));
        global.chart = [];
        return;
    }

    // -------------------------------
    // Boss-room-only PPS override (optional "pixels-per-beat" feel)
    // - Only applies when LEVEL_MODE == "boss" AND room == global.BOSS_ROOM
    // - Does NOT affect normal levels / Stage 1 baseline
    // -------------------------------
    var in_boss_room = false;

    if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss"
        && variable_global_exists("BOSS_ROOM") && room == global.BOSS_ROOM)
    {
        in_boss_room = true;
    }

    if (in_boss_room)
    {
        // Choose a constant pixels-per-beat for visual spacing consistency
        // (You can tune this per boss if you want.)
        if (!variable_global_exists("PX_PER_BEAT") || !is_real(global.PX_PER_BEAT) || global.PX_PER_BEAT <= 0)
            global.PX_PER_BEAT = 192;

        var bpm = (variable_global_exists("chart_bpm") && is_real(global.chart_bpm)) ? global.chart_bpm : 140;

        global.WORLD_PPS = global.PX_PER_BEAT * (bpm / 60.0);
        global.CHART_PPS = global.WORLD_PPS;

        show_debug_message("[scr_chart_load] Boss PPS override: bpm=" + string(bpm)
            + " px_per_beat=" + string(global.PX_PER_BEAT)
            + " pps=" + string(global.WORLD_PPS));
    }

    // -------------------------------
    // Normalize notes (LANE-FREE + Y-DRAGGABLE)
    // -------------------------------
    if (!variable_global_exists("ACT_ATK1")) global.ACT_ATK1 = "atk1";
    if (!variable_global_exists("ACT_JUMP")) global.ACT_JUMP = "jump";
    if (!variable_global_exists("ACT_DUCK")) global.ACT_DUCK = "duck";
    if (!variable_global_exists("SEC_PER_BEAT")) global.SEC_PER_BEAT = 60.0 / 140.0;

    var legacy_top = (variable_global_exists("GUI_TOP") ? global.GUI_TOP : 350);
    var legacy_bot = (variable_global_exists("GUI_BOT") ? global.GUI_BOT : 580);
    var legacy_spacing = (legacy_bot - legacy_top) / 3.0;

    for (var i = 0; i < array_length(global.chart); i++)
    {
        var nref = global.chart[i];

        if (!is_struct(nref))
        {
            global.chart[i] = {
                t: 0.0,
                lane: 0,
                type: "tap",
                act: global.ACT_ATK1,
                y_gui: (legacy_top + legacy_spacing),
                hit_fx_t: 0,
                hit_fx_dur: 0.10,
                hit_fx_pow: 0
            };
            continue;
        }

        if (!variable_struct_exists(nref, "t"))    nref.t = 0.0;
        if (!variable_struct_exists(nref, "lane")) nref.lane = 0;
        if (!variable_struct_exists(nref, "type")) nref.type = "tap";

        var lane_i = clamp(floor(nref.lane), 0, 3);

        if (!variable_struct_exists(nref, "act"))
        {
            if (!variable_global_exists("LANE_TO_ACT") || !is_array(global.LANE_TO_ACT) || array_length(global.LANE_TO_ACT) < 4) {
                global.LANE_TO_ACT = [ "atk1", "atk2", "atk3", "ult" ];
            }
            nref.act = global.LANE_TO_ACT[lane_i];
        }

        if (nref.act == global.ACT_JUMP || nref.act == global.ACT_DUCK) {
            nref.act = global.ACT_ATK1;
        }

        if (!variable_struct_exists(nref, "y_gui") || !is_real(nref.y_gui))
        {
            if (variable_global_exists("LANE_Y") && is_array(global.LANE_Y) && array_length(global.LANE_Y) >= 4) {
                nref.y_gui = global.LANE_Y[lane_i];
            } else {
                nref.y_gui = legacy_top + lane_i * legacy_spacing;
            }
        }

        nref.lane = 0;

        if (nref.type == "hold" && !variable_struct_exists(nref, "dur"))
        {
            nref.dur = global.SEC_PER_BEAT;
        }

        if (!variable_struct_exists(nref, "hit_fx_t")) nref.hit_fx_t = 0;
        if (!variable_struct_exists(nref, "hit_fx_dur")) nref.hit_fx_dur = 0.10;
        if (!variable_struct_exists(nref, "hit_fx_pow")) nref.hit_fx_pow = 0;
    }

    // Chart total length (seconds): latest note end + tail margin.
    var chart_end_s = 0.0;
    for (var ci = 0; ci < array_length(global.chart); ci++)
    {
        var cn = global.chart[ci];
        if (!is_struct(cn) || !variable_struct_exists(cn, "t") || !is_real(cn.t)) continue;

        var note_end_s = cn.t;
        if (variable_struct_exists(cn, "dur") && is_real(cn.dur))
            note_end_s += max(0, cn.dur);

        if (note_end_s > chart_end_s) chart_end_s = note_end_s;
    }

    var tail_margin_s = 2.0;
    if (variable_global_exists("CHART_LEN_TAIL_MARGIN_S") && is_real(global.CHART_LEN_TAIL_MARGIN_S))
        tail_margin_s = max(0, global.CHART_LEN_TAIL_MARGIN_S);

    global.CHART_LEN_S = chart_end_s + tail_margin_s;
    global.chart_len_s = global.CHART_LEN_S;

    scr_chart_sort();
    scr_attack_timeline_build();

    show_debug_message("[scr_chart_load] LOADED path=" + string(global.chart_loaded_path)
        + " notes=" + string(array_length(global.chart))
        + " diff=" + string(variable_global_exists("DIFFICULTY") ? global.DIFFICULTY : "??")
        + " chart_file=" + string(global.chart_file)
        + " bpm=" + string(variable_global_exists("chart_bpm") ? global.chart_bpm : -1)
        + " offset=" + string(variable_global_exists("chart_offset") ? global.chart_offset : -1));
}
