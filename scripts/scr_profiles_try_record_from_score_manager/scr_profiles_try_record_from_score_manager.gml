/// scr_profiles_try_record_from_score_manager()
function scr_profiles_try_record_from_score_manager()
{
    if (!object_exists(obj_score_manager) || !instance_exists(obj_score_manager)) return false;
    var sm = instance_find(obj_score_manager, 0);
    if (sm == noone) return false;

    var accuracy_raw = -1;
    if (variable_instance_exists(sm, "accuracy")) accuracy_raw = sm.accuracy;
    else if (variable_instance_exists(sm, "acc")) accuracy_raw = sm.acc;
    else if (variable_instance_exists(sm, "accuracy_pct")) accuracy_raw = sm.accuracy_pct;
    else if (variable_instance_exists(sm, "accuracy_percent")) accuracy_raw = sm.accuracy_percent;
    else if (variable_instance_exists(sm, "acc_pct")) accuracy_raw = sm.acc_pct;
    else if (variable_global_exists("score_state") && is_struct(global.score_state) && variable_struct_exists(global.score_state, "accuracy_percent")) accuracy_raw = global.score_state.accuracy_percent;

    if (accuracy_raw < 0) return false;

    var level_key = room_get_name(room);
    if (variable_global_exists("LEVEL_KEY") && string(global.LEVEL_KEY) != "") level_key = string(global.LEVEL_KEY);
    else if (script_exists(scr_level_key_current)) level_key = string(scr_level_key_current());

    var difficulty_key = "normal";
    if (variable_global_exists("difficulty")) difficulty_key = string_lower(string(global.difficulty));
    else if (variable_global_exists("DIFFICULTY")) difficulty_key = string_lower(string(global.DIFFICULTY));

    var accuracy01 = real(accuracy_raw);
    if (accuracy01 > 1.0) accuracy01 *= 0.01;
    accuracy01 = clamp(accuracy01, 0, 1);

    if (script_exists(scr_profiles_record_run)) {
        scr_profiles_record_run(level_key, difficulty_key, accuracy01);
        return true;
    }
    return false;
}
