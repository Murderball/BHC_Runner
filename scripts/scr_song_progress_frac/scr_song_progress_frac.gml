/// scr_song_progress_frac()
/// Returns current chart-time position as 0..1.
/// Uses the same time base as gameplay/editor notes via scr_chart_time().
function scr_song_progress_frac()
{
    var t = 0.0;
    if (script_exists(scr_chart_time)) t = scr_chart_time();

    var total_len_s = 0.0;

    if (variable_global_exists("CHART_LEN_S") && is_real(global.CHART_LEN_S) && global.CHART_LEN_S > 0)
    {
        total_len_s = global.CHART_LEN_S;
    }
    else if (variable_global_exists("SONG_LEN_S") && is_real(global.SONG_LEN_S) && global.SONG_LEN_S > 0)
    {
        total_len_s = global.SONG_LEN_S;
    }
    else if (variable_global_exists("chart_len_s") && is_real(global.chart_len_s) && global.chart_len_s > 0)
    {
        total_len_s = global.chart_len_s;
    }
    else if (variable_global_exists("song_len_s") && is_real(global.song_len_s) && global.song_len_s > 0)
    {
        total_len_s = global.song_len_s;
    }
    else if (variable_global_exists("chart") && is_array(global.chart))
    {
        // Fallback compute: latest note end + tail margin.
        var max_t = 0.0;
        for (var i = 0; i < array_length(global.chart); i++)
        {
            var n = global.chart[i];
            if (!is_struct(n) || !variable_struct_exists(n, "t") || !is_real(n.t)) continue;

            var note_end = n.t;
            if (variable_struct_exists(n, "dur") && is_real(n.dur)) note_end += max(0, n.dur);
            if (note_end > max_t) max_t = note_end;
        }

        var tail_margin = 2.0;
        if (variable_global_exists("CHART_LEN_TAIL_MARGIN_S") && is_real(global.CHART_LEN_TAIL_MARGIN_S))
            tail_margin = max(0, global.CHART_LEN_TAIL_MARGIN_S);

        total_len_s = max_t + tail_margin;
    }

    if (!is_real(total_len_s) || total_len_s <= 0) return 0.0;

    var denom_total_len = total_len_s;
if (denom_total_len == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_total_len = 1;
}
return clamp(t / denom_total_len, 0.0, 1.0);
}
