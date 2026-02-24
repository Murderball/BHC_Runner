/// scr_perf_init()
function scr_perf_init() {
    global.perf_total = 0;
    global.perf_hit   = 0;
    global.perf_score = 0;   // weighted score for accuracy %
    global.perf_streak = 0;
    global.perf_miss_streak = 0;

    global.perf_acc = 100;   // percent
    global.perf_window = 32; // rolling window size (events)

    // rolling window arrays
    global.perf_hist = array_create(global.perf_window, 1);      // 1 hit, 0 miss
    global.perf_hist_score = array_create(global.perf_window, 1); // weighted 0..1
    global.perf_hist_i = 0;

    // difficulty state
    global.diff_mode = 2; // 1 easy, 2 normal, 3 hard
    global.diff_target = 2;
    global.diff_lock_timer = 0; // prevents rapid flipping
}

/// scr_microprof_init()
/// Lightweight micro-profiler with rolling avg + worst spike.
function scr_microprof_init()
{
    if (variable_global_exists("microprof") && is_struct(global.microprof)) return;

    global.microprof = {
        enabled: true,
        draw_enabled: false,
        frame_start_us: 0,
        frame_avg_ms: 0.0,
        frame_worst_ms: 0.0,
        frame_window: 120,
        names: [],
        avg_ms: [],
        worst_ms: [],
        calls: [],
        last_ms: []
    };
}

/// scr_microprof_begin(name) -> timer token
function scr_microprof_begin(_name)
{
    if (!variable_global_exists("microprof") || !is_struct(global.microprof)) return 0;
    if (!global.microprof.enabled) return 0;
    return get_timer();
}

/// scr_microprof_end(name, token)
function scr_microprof_end(_name, _token)
{
    if (!variable_global_exists("microprof") || !is_struct(global.microprof)) return;
    if (!global.microprof.enabled) return;
    if (!is_real(_token) || _token <= 0) return;

    var ms = (get_timer() - _token) / 1000.0;
    if (!is_real(ms) || is_nan(ms)) return;

    var p = global.microprof;
    var names = p.names;

    var idx = -1;
    var n = array_length(names);
    for (var i = 0; i < n; i++) {
        if (names[i] == _name) { idx = i; break; }
    }

    if (idx < 0) {
        idx = n;
        array_push(p.names, _name);
        array_push(p.avg_ms, ms);
        array_push(p.worst_ms, ms);
        array_push(p.calls, 1);
        array_push(p.last_ms, ms);
    } else {
        var c = p.calls[idx] + 1;
        p.calls[idx] = c;
        p.last_ms[idx] = ms;

        var w = max(1, p.frame_window);
        var k = min(c, w);
        var denom_k = k;
    if (denom_k == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_k = 1;
    }
    p.avg_ms[idx] = p.avg_ms[idx] + ((ms - p.avg_ms[idx]) / denom_k);
        if (ms > p.worst_ms[idx]) p.worst_ms[idx] = ms;
    }

    global.microprof = p;
}

/// scr_microprof_frame_begin()
function scr_microprof_frame_begin()
{
    if (!variable_global_exists("microprof") || !is_struct(global.microprof)) return;
    if (!global.microprof.enabled) return;
    global.microprof.frame_start_us = get_timer();
}

/// scr_microprof_frame_end()
function scr_microprof_frame_end()
{
    if (!variable_global_exists("microprof") || !is_struct(global.microprof)) return;
    if (!global.microprof.enabled) return;

    var t0 = global.microprof.frame_start_us;
    if (!is_real(t0) || t0 <= 0) return;

    var ms = (get_timer() - t0) / 1000.0;
    if (!is_real(ms) || is_nan(ms)) return;

    var p = global.microprof;
    var w = max(1, p.frame_window);
    var denom_w = w;
    if (denom_w == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_w = 1;
    }
    p.frame_avg_ms = p.frame_avg_ms + ((ms - p.frame_avg_ms) / denom_w);
    if (ms > p.frame_worst_ms) p.frame_worst_ms = ms;

    global.microprof = p;
}

/// scr_microprof_draw_overlay(x, y, rows)
function scr_microprof_draw_overlay(_x, _y, _rows)
{
    if (!variable_global_exists("microprof") || !is_struct(global.microprof)) return;
    if (!global.microprof.draw_enabled) return;

    var p = global.microprof;
    var n = array_length(p.names);
    if (n <= 0) return;

    var rows = max(1, _rows);
    var idxs = [];
    for (var i = 0; i < n; i++) array_push(idxs, i);

    // Partial selection-sort for top rows by avg ms.
    for (var a = 0; a < min(rows, n); a++) {
        var best = a;
        for (var b = a + 1; b < n; b++) {
            if (p.avg_ms[idxs[b]] > p.avg_ms[idxs[best]]) best = b;
        }
        if (best != a) {
            var t = idxs[a];
            idxs[a] = idxs[best];
            idxs[best] = t;
        }
    }

    draw_set_font(-1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    var lh = 16;
    var pad = 6;
    var title = "MicroProfiler (F3) frame avg=" + string_format(p.frame_avg_ms, 0, 3)
        + "ms worst=" + string_format(p.frame_worst_ms, 0, 3) + "ms";

    var maxw = string_width(title);
    var lim = min(rows, n);
    for (var r = 0; r < lim; r++) {
        var ii = idxs[r];
        var line = string(r + 1) + ". " + p.names[ii]
            + " avg=" + string_format(p.avg_ms[ii], 0, 3)
            + "ms worst=" + string_format(p.worst_ms[ii], 0, 3)
            + "ms last=" + string_format(p.last_ms[ii], 0, 3)
            + "ms calls=" + string(p.calls[ii]);
        maxw = max(maxw, string_width(line));
    }

    var box_h = pad * 2 + lh * (1 + lim);
    var box_w = maxw + pad * 2;

    draw_set_color(c_black);
    draw_set_alpha(0.65);
    draw_rectangle(_x, _y, _x + box_w, _y + box_h, false);

    draw_set_alpha(1);
    draw_set_color(c_lime);
    draw_text(_x + pad, _y + pad, title);

    for (var rr = 0; rr < lim; rr++) {
        var iii = idxs[rr];
        var line2 = string(rr + 1) + ". " + p.names[iii]
            + " avg=" + string_format(p.avg_ms[iii], 0, 3)
            + "ms worst=" + string_format(p.worst_ms[iii], 0, 3)
            + "ms last=" + string_format(p.last_ms[iii], 0, 3);
        draw_text(_x + pad, _y + pad + lh * (rr + 1), line2);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

// Ensure attack timeline lists exist (empty until chart loads)
if (!variable_global_exists("atk_times_1")) global.atk_times_1 = ds_list_create();
if (!variable_global_exists("atk_times_2")) global.atk_times_2 = ds_list_create();
if (!variable_global_exists("atk_times_3")) global.atk_times_3 = ds_list_create();
