/// scr_score_reset_run()
/// Resets per-attempt score values while keeping current config.
function scr_score_reset_run()
{
    if (!variable_global_exists("score_state") || !is_struct(global.score_state)) {
        scr_score_init();
        return;
    }

    var _st = global.score_state;
    var _cfg = _st.config;

    _st.score_total = 0;
    _st.combo = 0;
    _st.max_combo = 0;
    _st.multiplier = _cfg.mult_base;
    _st.multiplier_target = _cfg.mult_base;
    _st.multiplier_lock_until_ms = 0;
    _st.accuracy_percent = 100.0;

    _st.count_perfect = 0;
    _st.count_good = 0;
    _st.count_bad = 0;
    _st.count_miss = 0;
    _st.notes_total = 0;
    _st.notes_hit = 0;

    _st.rolling_accuracy = 1.0;
    _st.rolling_sum = 0.0;
    _st.rolling_count = 0;
    _st.rolling_index = 0;
    _st.rolling_window = array_create(_cfg.rolling_window_size, 1.0);

    _st.score_breakdown.points_perfect = 0;
    _st.score_breakdown.points_good = 0;
    _st.score_breakdown.points_bad = 0;
    _st.score_breakdown.points_miss = 0;
    _st.score_breakdown.points_combo_bonus = 0;
    _st.score_breakdown.last_judge = "";
    _st.score_breakdown.last_base_points = 0;
    _st.score_breakdown.last_meta = undefined;
    _st.score_breakdown.last_points_awarded = 0;
    _st.score_breakdown.last_target_multiplier = _cfg.mult_base;
    _st.score_breakdown.last_applied_multiplier = _cfg.mult_base;
}
