function scr_try_hit(lane) {
    var t = scr_chart_time();


    // Find closest note in this lane within BAD window
    var best_i = -1;
    var best_dt = 9999;

    var len = array_length(global.chart);
    for (var i = 0; i < len; i++) {
        var n = global.chart[i];
        if (n.lane != lane) continue;

        var dt = abs(n.t - t);

        // ignore notes too far away
        if (dt > global.WIN_BAD) continue;

        if (dt < best_dt) {
            best_dt = dt;
            best_i = i;
        }
    }

    if (best_i < 0) return "miss";

    // Judge
    var result = "good";
    if (best_dt <= global.WIN_PERFECT) result = "perfect";
    else if (best_dt <= global.WIN_GOOD) result = "good";
    else result = "bad";

    // Remove note from chart (for now)
    array_delete(global.chart, best_i, 1);

    return result;
}
