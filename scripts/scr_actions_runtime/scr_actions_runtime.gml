function scr_actions_update(dt_s)
{
    if (!variable_instance_exists(id, "act_cd")) return;
    if (!variable_instance_exists(id, "ult_meter")) id.ult_meter = 0;

    for (var i = 0; i < ACT.COUNT; i++) {
        act_cd[i] = max(0, act_cd[i] - dt_s);
    }

    if (variable_instance_exists(id, "ultimate_meter")) {
        ult_meter = clamp(ultimate_meter, 0, 100);
    }
}

function scr_action_try(act_id)
{
    if (!variable_global_exists("actions_inited") || !global.actions_inited) {
        if (script_exists(scr_actions_init)) scr_actions_init();
        if (!variable_global_exists("actions_inited") || !global.actions_inited) return false;
    }

    if (!variable_instance_exists(id, "char_id")) return false;
    if (!variable_instance_exists(id, "act_cd")) return false;

    var def = global.action_defs[char_id][act_id];
    if (!is_struct(def)) return false;
    if (act_cd[act_id] > 0) return false;
    if (!def.can(id, act_id, def)) return false;

    if (def.cost > 0) {
        ult_meter = variable_instance_exists(id, "ultimate_meter") ? clamp(ultimate_meter, 0, 100) : clamp(ult_meter, 0, 100);
        if (ult_meter < def.cost) return false;
    }

    var ok = def.exec(id, act_id, def);
    if (!ok) return false;

    if (def.cost > 0) {
        ult_meter = clamp(ult_meter - def.cost, 0, 100);
        if (variable_instance_exists(id, "ultimate_meter")) ultimate_meter = ult_meter;
    }

    act_cd[act_id] = def.cd_s;

    if (variable_global_exists("DEBUG_ACTIONS") && global.DEBUG_ACTIONS) {
        show_debug_message("[actions] " + object_get_name(object_index) + " -> " + def.name);
    }
    return true;
}
