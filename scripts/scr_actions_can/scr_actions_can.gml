function scr_act_can_default(p, act, def)
{
    if (variable_instance_exists(p, "stunned") && p.stunned) return false;
    if (variable_instance_exists(p, "disabled") && p.disabled) return false;
    if (variable_instance_exists(p, "can_act") && !p.can_act) return false;
    return true;
}

function scr_act_can_jump(p, act, def)
{
    if (!scr_act_can_default(p, act, def)) return false;
    var grounded_now = variable_instance_exists(p, "is_grounded") ? p.is_grounded : (variable_instance_exists(p, "grounded") ? p.grounded : false);
    var ducking_now = variable_instance_exists(p, "is_ducking") ? p.is_ducking : (variable_instance_exists(p, "duck_timer") ? (p.duck_timer > 0) : false);
    return grounded_now && !ducking_now;
}

function scr_act_can_duck(p, act, def)
{
    if (!scr_act_can_default(p, act, def)) return false;
    return variable_instance_exists(p, "is_grounded") ? p.is_grounded : (variable_instance_exists(p, "grounded") ? p.grounded : false);
}

function scr_act_can_ult(p, act, def)
{
    if (!scr_act_can_default(p, act, def)) return false;
    if ((variable_global_exists("STORY_PAUSED") && global.STORY_PAUSED) || (variable_global_exists("STARTUP_LOADING") && global.STARTUP_LOADING)) return false;
    return p.ult_meter >= def.cost;
}
