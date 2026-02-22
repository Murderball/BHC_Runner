/// scr_score_init()
/// Creates/repairs global.score_state and applies default scoring config.
function scr_score_init()
{
    var _cfg = {
        // ===== Multiplier limits + smoothing =====
        mult_min                : 0.25,
        mult_max                : 6.0,
        mult_base               : 1.0,
        mult_rise_rate          : 0.20, // 0..1, how fast current mult lerps to target
        mult_lock_ms_after_miss : 500,  // lockout period where multiplier cannot rise

        // ===== Divider behavior =====
        bad_divider             : 1.25, // on bad: multiplier /= 1.25
        miss_divider            : 1.75, // on miss: multiplier /= 1.75

        // ===== Combo behavior =====
        bad_combo_penalty       : 2,    // reduce combo by this amount on bad
        miss_breaks_combo       : true,
        combo_tier_divisor      : 50.0, // larger => slower growth
        combo_tier_max_boost    : 0.75, // combo tier max = 1 + this value

        // ===== Accuracy tracking =====
        rolling_window_size     : 32,

        // values used for rolling window average (stability/consistency metric)
        roll_value_perfect      : 1.00,
        roll_value_good         : 0.75,
        roll_value_bad          : 0.35,
        roll_value_miss         : 0.00,

        // points weight by judgement (actual awarded points)
        judge_weight_perfect    : 1.00,
        judge_weight_good       : 0.85,
        judge_weight_bad        : 0.40,
        judge_weight_miss       : 0.00,

        // optional additive bonus scaling with combo (set to 0 to disable)
        combo_bonus_per_combo   : 0.00,
        combo_bonus_cap         : 50.0,

        // ===== Accuracy tiers (rolling accuracy -> multiplier tier) =====
        // Ordered high to low and easy to tweak.
        acc_tier_thresholds     : [0.98, 0.95, 0.90, 0.80, 0.65, 0.00],
        acc_tier_values         : [2.00, 1.75, 1.50, 1.25, 1.00, 0.75]
    };

    global.score_state = {
        config               : _cfg,

        // public run stats
        score_total          : 0,
        combo                : 0,
        max_combo            : 0,
        multiplier           : _cfg.mult_base, // current smoothed multiplier
        multiplier_target    : _cfg.mult_base,
        multiplier_lock_until_ms : 0,
        accuracy_percent     : 100.0,

        count_perfect        : 0,
        count_good           : 0,
        count_bad            : 0,
        count_miss           : 0,
        notes_total          : 0,
        notes_hit            : 0,

        rolling_accuracy     : 1.0,
        rolling_sum          : 0.0,
        rolling_count        : 0,
        rolling_index        : 0,
        rolling_window       : array_create(_cfg.rolling_window_size, 1.0),

        // debug-friendly breakdown struct
        score_breakdown : {
            points_perfect : 0,
            points_good    : 0,
            points_bad     : 0,
            points_miss    : 0,
            points_combo_bonus : 0,
            last_judge     : "",
            last_base_points : 0,
            last_meta      : undefined,
            last_points_awarded : 0,
            last_target_multiplier : _cfg.mult_base,
            last_applied_multiplier : _cfg.mult_base
        }
    };

    if (!variable_global_exists("DEBUG_SCORE")) global.DEBUG_SCORE = false;
}
