/// scr_editor_delete_enemy_at_cursor()
/// Deletes the closest enemy near editor cursor time and lane.

function scr_editor_delete_enemy_at_cursor()
{
    if (!variable_global_exists("chart")) return;
    if (!is_array(global.chart)) return;

    var t_now = global.editor_time;
    var lane_now = scr_editor_lane_from_mouse();

    var bpm = 140.0;
    if (variable_global_exists("BPM") && is_real(global.BPM) && global.BPM > 0) bpm = global.BPM;
    var denom_bpm = bpm;
    if (denom_bpm == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_bpm = 1;
    }
    var beat_s = 60.0 / denom_bpm;

    var denom_tol = 8.0;
    if (denom_tol == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_tol = 1;
    }
    var tol_t = beat_s / denom_tol;
    if (variable_global_exists("SNAP_DIV") && is_real(global.SNAP_DIV) && global.SNAP_DIV > 0)
    {
        var denom_snap = global.SNAP_DIV;
        if (denom_snap == 0)
        {
            show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
            denom_snap = 1;
        }
        tol_t = (beat_s * (4.0 / denom_snap)) * 0.5;
    }

    var best_index = -1;
    var best_metric = 1000000000;

	if (!variable_global_exists("enemy_delete_latch")) global.enemy_delete_latch = false;
	if (global.enemy_delete_latch) return;
	global.enemy_delete_latch = true;

    var len = array_length(global.chart);
    for (var i = 0; i < len; i++)
    {
        var n = global.chart[i];
        if (!is_struct(n)) continue;
        if (!variable_struct_exists(n, "type")) continue;
        if (n.type != "enemy") continue;
        if (!variable_struct_exists(n, "t")) continue;

        var dt = abs(n.t - t_now);
        if (dt > tol_t) continue;

        var n_lane = 0;
        if (variable_struct_exists(n, "lane")) n_lane = n.lane;

        var dl = abs(n_lane - lane_now);

        // renamed from "score" -> "best_metric"
        var metric = dt + (dl * tol_t);

        if (metric < best_metric)
        {
            best_metric = metric;
            best_index = i;
        }
    }

    if (best_index != -1)
    {
        array_delete(global.chart, best_index, 1);
    }
}
