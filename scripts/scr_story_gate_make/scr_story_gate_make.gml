function scr_story_gate_make(_t, _target, _return_mode, _one_shot, _payload)
{
    var _mode = is_string(_return_mode) ? _return_mode : "resume";
    var _one = is_bool(_one_shot) ? _one_shot : true;
    var _pay = is_struct(_payload) ? _payload : {};

    return {
        kind: "story_gate",
        t: real(_t),
        target: _target,
        return_mode: _mode,
        one_shot: _one,
        payload: _pay,
        consumed: false
    };
}
