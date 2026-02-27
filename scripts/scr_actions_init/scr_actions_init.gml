function scr_action_def(name, cd_s, cost, exec_fn, can_fn)
{
    return {
        name: name,
        cd_s: cd_s,
        cost: cost,
        exec: exec_fn,
        can: can_fn
    };
}

function scr_actions_init()
{
    global.action_defs = array_create(CHAR.COUNT);
    for (var c = 0; c < CHAR.COUNT; c++) {
        global.action_defs[c] = array_create(ACT.COUNT);
    }

    for (var c2 = 0; c2 < CHAR.COUNT; c2++) {
        global.action_defs[c2][ACT.JUMP] = scr_action_def("Jump", 0, 0, scr_act_exec_jump, scr_act_can_jump);
        global.action_defs[c2][ACT.DUCK] = scr_action_def("Duck", 0, 0, scr_act_exec_duck, scr_act_can_duck);
    }

    global.action_defs[CHAR.GUITAR][ACT.ATK1] = scr_action_def("Riff Shot", 0.15, 0, scr_act_exec_atk1, scr_act_can_default);
    global.action_defs[CHAR.GUITAR][ACT.ATK2] = scr_action_def("Chord Slash", 0.60, 0, scr_act_exec_atk2, scr_act_can_default);
    global.action_defs[CHAR.GUITAR][ACT.ATK3] = scr_action_def("Feedback Pulse", 1.50, 0, scr_act_exec_atk3, scr_act_can_default);
    global.action_defs[CHAR.GUITAR][ACT.ULT] = scr_action_def("Prism Solo", 8.00, 100, scr_act_exec_ult, scr_act_can_ult);

    global.action_defs[CHAR.VOCAL][ACT.ATK1] = scr_action_def("Sonic Note", 0.20, 0, scr_act_exec_atk1, scr_act_can_default);
    global.action_defs[CHAR.VOCAL][ACT.ATK2] = scr_action_def("Chorus Shield", 2.50, 0, scr_act_exec_atk2, scr_act_can_default);
    global.action_defs[CHAR.VOCAL][ACT.ATK3] = scr_action_def("Crowd Control", 3.00, 0, scr_act_exec_atk3, scr_act_can_default);
    global.action_defs[CHAR.VOCAL][ACT.ULT] = scr_action_def("Anthem Surge", 10.0, 100, scr_act_exec_ult, scr_act_can_ult);

    global.action_defs[CHAR.BASS][ACT.ATK1] = scr_action_def("Low Wave", 0.25, 0, scr_act_exec_atk1, scr_act_can_default);
    global.action_defs[CHAR.BASS][ACT.ATK2] = scr_action_def("Ground Slam", 1.20, 0, scr_act_exec_atk2, scr_act_can_default);
    global.action_defs[CHAR.BASS][ACT.ATK3] = scr_action_def("Gravity Groove", 4.00, 0, scr_act_exec_atk3, scr_act_can_default);
    global.action_defs[CHAR.BASS][ACT.ULT] = scr_action_def("Subquake", 10.0, 100, scr_act_exec_ult, scr_act_can_ult);

    global.action_defs[CHAR.DRUM][ACT.ATK1] = scr_action_def("Snare Shot", 0.10, 0, scr_act_exec_atk1, scr_act_can_default);
    global.action_defs[CHAR.DRUM][ACT.ATK2] = scr_action_def("Cymbal Crash", 1.80, 0, scr_act_exec_atk2, scr_act_can_default);
    global.action_defs[CHAR.DRUM][ACT.ATK3] = scr_action_def("Tempo Boost", 6.00, 0, scr_act_exec_atk3, scr_act_can_default);
    global.action_defs[CHAR.DRUM][ACT.ULT] = scr_action_def("Overdrive", 9.00, 100, scr_act_exec_ult, scr_act_can_ult);

    global.actions_inited = true;
}
