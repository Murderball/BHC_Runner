/// scr_chart_now_time()
/// Returns the time that chart visuals/judgement should use.
/// Positive CHART_OFFSET_S pushes chart LATER.
function scr_chart_now_time()
{
    var t = scr_song_time();

    if (variable_global_exists("CHART_OFFSET_S")) {
        t -= global.CHART_OFFSET_S;
    }

    return t;
}
