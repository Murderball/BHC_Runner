function scr_recorder_event_from_keypress(_t, _take_events)
{
    var bpm_now = scr_recorder_get_bpm();
    if (!is_real(bpm_now) || bpm_now <= 0) return false;
    if (!is_array(_take_events)) return false;

    var pushed_any = false;
    var q;
    var ev;

    if (keyboard_check_pressed(vk_space))
    {
        q = scr_recorder_quantize_to_eighth(_t, bpm_now);
        ev = {
            t: real(_t),
            kind: "jump",
            act: global.ACT_JUMP,
            spr: spr_note_jump,
            lane: 0,
            grid8: q.grid8,
            err: q.err,
            grid_time: q.grid_time
        };
        array_push(_take_events, ev);
        pushed_any = true;
    }

    if (keyboard_check_pressed(vk_lshift) || keyboard_check_pressed(vk_rshift))
    {
        q = scr_recorder_quantize_to_eighth(_t, bpm_now);
        ev = {
            t: real(_t),
            kind: "duck",
            act: global.ACT_DUCK,
            spr: spr_note_duck,
            lane: 0,
            grid8: q.grid8,
            err: q.err,
            grid_time: q.grid_time
        };
        array_push(_take_events, ev);
        pushed_any = true;
    }

    if (keyboard_check_pressed(ord("1")))
    {
        q = scr_recorder_quantize_to_eighth(_t, bpm_now);
        ev = {
            t: real(_t),
            kind: "atk1",
            act: global.ACT_ATK1,
            spr: spr_note_attk1,
            lane: 0,
            grid8: q.grid8,
            err: q.err,
            grid_time: q.grid_time
        };
        array_push(_take_events, ev);
        pushed_any = true;
    }

    if (keyboard_check_pressed(ord("2")))
    {
        var atk2_spr = spr_note_attk2;
        if (script_exists(scr_note_sprite_index)) atk2_spr = scr_note_sprite_index(global.ACT_ATK2);

        q = scr_recorder_quantize_to_eighth(_t, bpm_now);
        ev = {
            t: real(_t),
            kind: "atk2",
            act: global.ACT_ATK2,
            spr: atk2_spr,
            lane: 1,
            grid8: q.grid8,
            err: q.err,
            grid_time: q.grid_time
        };
        if (variable_global_exists("DEBUG_INPUT") && global.DEBUG_INPUT) {
            show_debug_message("ATK2 key pressed -> kind=" + string(ev.kind)
                + " act=" + string(ev.act)
                + " sprite=" + string(ev.spr));
        }
        array_push(_take_events, ev);
        pushed_any = true;
    }

    if (keyboard_check_pressed(ord("3")))
    {
        q = scr_recorder_quantize_to_eighth(_t, bpm_now);
        ev = {
            t: real(_t),
            kind: "atk3",
            act: global.ACT_ATK3,
            spr: spr_note_attk3,
            lane: 2,
            grid8: q.grid8,
            err: q.err,
            grid_time: q.grid_time
        };
        array_push(_take_events, ev);
        pushed_any = true;
    }

    if (keyboard_check_pressed(ord("4")))
    {
        q = scr_recorder_quantize_to_eighth(_t, bpm_now);
        ev = {
            t: real(_t),
            kind: "ultimate",
            act: global.ACT_ULT,
            spr: spr_note_ultimate,
            lane: 3,
            grid8: q.grid8,
            err: q.err,
            grid_time: q.grid_time
        };
        array_push(_take_events, ev);
        pushed_any = true;
    }

    return pushed_any;
}
