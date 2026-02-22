function scr_room_gate_make(_t, _target, _return_mode, _one_shot)
{
    var m = {
        kind: "room_gate",
        t: _t,
        target: _target,
        return_mode: is_undefined(_return_mode) ? "resume" : _return_mode,
        one_shot: is_undefined(_one_shot) ? true : _one_shot,
        consumed: false
    };

    return m;
}
