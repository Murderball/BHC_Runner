/// scr_score_get_snapshot()
/// Returns a read-friendly copy for UI/debug drawing.
function scr_score_get_snapshot()
{
    if (!variable_global_exists("score_state") || !is_struct(global.score_state)) {
        scr_score_init();
    }

    var _st = global.score_state;

    return {
        score_total       : _st.score_total,
        combo             : _st.combo,
        max_combo         : _st.max_combo,
        multiplier        : _st.multiplier,
        multiplier_target : _st.multiplier_target,
        accuracy_percent  : _st.accuracy_percent,
        rolling_accuracy  : _st.rolling_accuracy,

        count_perfect     : _st.count_perfect,
        count_good        : _st.count_good,
        count_bad         : _st.count_bad,
        count_miss        : _st.count_miss,
        notes_total       : _st.notes_total,
        notes_hit         : _st.notes_hit,

        score_breakdown   : _st.score_breakdown
    };
}
