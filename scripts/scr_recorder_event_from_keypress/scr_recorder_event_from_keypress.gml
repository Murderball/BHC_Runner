function scr_recorder_event_from_keypress(t)
{
    var events = [];

    var bpm = (variable_global_exists("chart_bpm") && is_real(global.chart_bpm) && global.chart_bpm > 0)
        ? global.chart_bpm
        : ((variable_global_exists("BPM") && is_real(global.BPM) && global.BPM > 0) ? global.BPM : 120);

    var push_event = function(_kind, _act, _spr, _lane)
    {
        var q = scr_recorder_quantize_to_eighth(t, bpm);
        var ev = {
            t: real(t),
            kind: _kind,
            act: _act,
            spr: _spr,
            lane: _lane,
            grid8: q.grid8,
            err: q.err,
            grid_time: q.grid_time
        };
        array_push(events, ev);
    };

    if (keyboard_check_pressed(vk_space)) push_event("jump", global.ACT_JUMP, spr_note_jump, 0);
    if (keyboard_check_pressed(vk_shift)) push_event("duck", global.ACT_DUCK, spr_note_duck, 0);
    if (keyboard_check_pressed(ord("1"))) push_event("atk1", global.ACT_ATK1, spr_note_atk1, 0);
    if (keyboard_check_pressed(ord("2"))) push_event("atk2", global.ACT_ATK2, spr_note_atk2, 1);
    if (keyboard_check_pressed(ord("3"))) push_event("atk3", global.ACT_ATK3, spr_note_atk3, 2);
    if (keyboard_check_pressed(ord("4"))) push_event("ult",  global.ACT_ULT,  spr_note_ultimate, 3);

    return events;
}
