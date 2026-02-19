/// scr_perf_grade(judge)
// judge: "perfect" | "good" | "bad" | "miss"

function scr_perf_grade(judge) {

    // Weighting tuned for your 4-tier system
    var w = 1.0;

    if (judge == "perfect") w = 1.0;
    else if (judge == "good") w = 0.85;
    else if (judge == "bad") w = 0.45;
    else if (judge == "miss") w = 0.0;
    else w = 0.0;

    // rolling window arrays must exist
    if (!variable_global_exists("perf_window")) scr_perf_init();

    // store
    global.perf_hist_score[global.perf_hist_i] = w;
    global.perf_hist_i = (global.perf_hist_i + 1) mod global.perf_window;

    // streaks (hit = anything but miss)
    if (judge != "miss") {
        global.perf_streak += 1;
        global.perf_miss_streak = 0;
    } else {
        global.perf_miss_streak += 1;
        global.perf_streak = 0;
    }

    // compute weighted accuracy %
    var sum_w = 0;
    for (var i = 0; i < global.perf_window; i++) sum_w += global.perf_hist_score[i];
    global.perf_acc = round((sum_w / global.perf_window) * 100);

    // difficulty target logic w/ hysteresis + lockout
    if (global.diff_lock_timer > 0) global.diff_lock_timer--;

    if (global.diff_lock_timer <= 0) {
        // Hysteresis: different thresholds to enter vs leave
        // Enter hard at 90+, leave hard below 85
        // Enter easy at 50-, leave easy above 58
        var target = 2;

        if (global.diff_mode == 3) {
            target = (global.perf_acc < 85) ? 2 : 3;
        } else if (global.diff_mode == 1) {
            target = (global.perf_acc > 58) ? 2 : 1;
        } else {
            if (global.perf_acc >= 90) target = 3;
            else if (global.perf_acc <= 50) target = 1;
            else target = 2;
        }

        if (target != global.diff_mode) {
            global.diff_mode = target;
            global.diff_lock_timer = room_speed * 2; // 2 seconds lock
        }
    }
}
