/// scr_score_on_judge(judge_string, base_points, lane_or_kind_optional)
/// Main entry point for note judgements.
function scr_score_on_judge(_judge_string, _base_points, _meta)
{
    if (!variable_global_exists("score_state") || !is_struct(global.score_state)) {
        scr_score_init();
    }

    var _st = global.score_state;
    var _cfg = _st.config;

    var _judge = string_lower(string(_judge_string));
    if ((_judge != "perfect") && (_judge != "good") && (_judge != "bad") && (_judge != "miss")) {
        _judge = "miss";
    }

    var _base = max(0, floor(_base_points));
    var _now_ms = current_time;

    // ---- judgement constants ----
    var _roll_value = _cfg.roll_value_miss;
    var _judge_weight = _cfg.judge_weight_miss;

    switch (_judge)
    {
        case "perfect":
            _roll_value = _cfg.roll_value_perfect;
            _judge_weight = _cfg.judge_weight_perfect;
            _st.count_perfect += 1;
            _st.notes_hit += 1;
            _st.combo += 1;
        break;

        case "good":
            _roll_value = _cfg.roll_value_good;
            _judge_weight = _cfg.judge_weight_good;
            _st.count_good += 1;
            _st.notes_hit += 1;
            _st.combo += 1;
        break;

        case "bad":
            _roll_value = _cfg.roll_value_bad;
            _judge_weight = _cfg.judge_weight_bad;
            _st.count_bad += 1;
            _st.notes_hit += 1;
            _st.combo = max(0, _st.combo - _cfg.bad_combo_penalty);
            var denom_bad = _cfg.bad_divider;
    if (denom_bad == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_bad = 1;
    }
    _st.multiplier = _st.multiplier / denom_bad;
        break;

        case "miss":
            _roll_value = _cfg.roll_value_miss;
            _judge_weight = _cfg.judge_weight_miss;
            _st.count_miss += 1;
            if (_cfg.miss_breaks_combo) _st.combo = 0;
            var denom_miss = _cfg.miss_divider;
    if (denom_miss == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_miss = 1;
    }
    _st.multiplier = _st.multiplier / denom_miss;
            _st.multiplier_lock_until_ms = _now_ms + _cfg.mult_lock_ms_after_miss;
        break;
    }

    _st.notes_total += 1;
    _st.max_combo = max(_st.max_combo, _st.combo);

    // ---- rolling accuracy ring buffer update ----
    var _idx = _st.rolling_index;
    var _was_count = _st.rolling_count;

    if (_was_count < _cfg.rolling_window_size) {
        _st.rolling_sum += _roll_value;
        _st.rolling_count += 1;
    } else {
        _st.rolling_sum -= _st.rolling_window[_idx];
        _st.rolling_sum += _roll_value;
    }

    _st.rolling_window[_idx] = _roll_value;
    _st.rolling_index = (_idx + 1) mod _cfg.rolling_window_size;
    var denom_rolling = _st.rolling_count;
if (denom_rolling == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_rolling = 1;
}
_st.rolling_accuracy = (_st.rolling_count > 0) ? (_st.rolling_sum / denom_rolling) : 1.0;

    // ---- overall (all notes) accuracy ----
    var _acc_sum = (_st.count_perfect * _cfg.roll_value_perfect)
                 + (_st.count_good    * _cfg.roll_value_good)
                 + (_st.count_bad     * _cfg.roll_value_bad)
                 + (_st.count_miss    * _cfg.roll_value_miss);

    if (_st.notes_total > 0) {
        var denom_notes = _st.notes_total;
if (denom_notes == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_notes = 1;
}
_st.accuracy_percent = clamp((_acc_sum / denom_notes) * 100.0, 0.0, 100.0);
    } else {
        _st.accuracy_percent = 100.0;
    }

    // ---- accuracy tier from rolling window ----
    var _acc_tier = _cfg.acc_tier_values[array_length(_cfg.acc_tier_values) - 1];
    var _tier_len = min(array_length(_cfg.acc_tier_thresholds), array_length(_cfg.acc_tier_values));
    for (var _i = 0; _i < _tier_len; _i++) {
        if (_st.rolling_accuracy >= _cfg.acc_tier_thresholds[_i]) {
            _acc_tier = _cfg.acc_tier_values[_i];
            break;
        }
    }

    // ---- smooth combo tier ----
    var denom_combo = _cfg.combo_tier_divisor;
if (denom_combo == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_combo = 1;
}
var _combo_norm = min(_st.combo / denom_combo, 1.0);
    var _combo_tier = 1.0 + (_combo_norm * _cfg.combo_tier_max_boost);

    _st.multiplier_target = _cfg.mult_base * _acc_tier * _combo_tier;
    _st.multiplier_target = clamp(_st.multiplier_target, _cfg.mult_min, _cfg.mult_max);

    // Multiplier rise lock: cannot increase while locked, but can still decrease.
    var _can_rise = (_now_ms >= _st.multiplier_lock_until_ms);

    if (_can_rise) {
        _st.multiplier = lerp(_st.multiplier, _st.multiplier_target, _cfg.mult_rise_rate);
    } else {
        _st.multiplier = min(_st.multiplier, _st.multiplier_target);
    }

    _st.multiplier = clamp(_st.multiplier, _cfg.mult_min, _cfg.mult_max);

    // ---- points ----
    var _combo_bonus = min(_cfg.combo_bonus_cap, _st.combo * _cfg.combo_bonus_per_combo);
    var _points_awarded = round((_base * _st.multiplier * _judge_weight) + _combo_bonus);

    var _hit_reason = "HIT";
    if (is_struct(_meta) && variable_struct_exists(_meta, "hit_reason")) _hit_reason = _meta.hit_reason;
    _points_awarded = scr_score_award(_hit_reason, _points_awarded, 1.0);

    // ---- breakdown/debug bookkeeping ----
    switch (_judge)
    {
        case "perfect": _st.score_breakdown.points_perfect += _points_awarded; break;
        case "good":    _st.score_breakdown.points_good += _points_awarded; break;
        case "bad":     _st.score_breakdown.points_bad += _points_awarded; break;
        case "miss":    _st.score_breakdown.points_miss += _points_awarded; break;
    }

    _st.score_breakdown.points_combo_bonus += _combo_bonus;
    _st.score_breakdown.last_judge = _judge;
    _st.score_breakdown.last_base_points = _base;
    _st.score_breakdown.last_meta = _meta;
    _st.score_breakdown.last_points_awarded = _points_awarded;
    _st.score_breakdown.last_target_multiplier = _st.multiplier_target;
    _st.score_breakdown.last_applied_multiplier = _st.multiplier;

    return _points_awarded;
}


/// scr_score_base_points(note_kind_or_action)
function scr_score_base_points(_kind)
{
    var _k = string_lower(string(_kind));

    if (variable_global_exists("ACT_ATK1") && _kind == global.ACT_ATK1) _k = "atk1";
    else if (variable_global_exists("ACT_ATK2") && _kind == global.ACT_ATK2) _k = "atk2";
    else if (variable_global_exists("ACT_ATK3") && _kind == global.ACT_ATK3) _k = "atk3";
    else if (variable_global_exists("ACT_ULT") && _kind == global.ACT_ULT) _k = "ult";
    else if (variable_global_exists("ACT_JUMP") && _kind == global.ACT_JUMP) _k = "jump";
    else if (variable_global_exists("ACT_DUCK") && _kind == global.ACT_DUCK) _k = "duck";

    switch (_k)
    {
        case "atk1":
        case "attack1":
            return 100;

        case "atk2":
        case "attack2":
            return 110;

        case "atk3":
        case "attack3":
            return 120;

        case "ult":
        case "ultimate":
            return 150;

        case "jump":
        case "duck":
            return 90;
    }

    return 100;
}
