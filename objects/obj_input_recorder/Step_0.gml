/// obj_input_recorder : Step

editor_mode = (variable_global_exists("editor_on") && global.editor_on);
if (!editor_mode) exit;

if (!variable_global_exists("input_recorder") || !is_struct(global.input_recorder)) exit;
if (!global.input_recorder.enabled) exit;

if (keyboard_check_pressed(vk_f9)) {
    if (global.input_recorder.recording) global.input_recorder.stop();
    else global.input_recorder.start();
}
if (keyboard_check_pressed(vk_f10)) {
    global.input_recorder.clear();
}

var pad = variable_global_exists("pad") ? global.pad : 0;
var has_pad = gamepad_is_connected(pad);

// Use gameplay mappings from scr_input_update
var kb_jump_raw = vk_space;
var kb_duck_raw = vk_shift;
var kb_a1_raw = ord("1");
var kb_a2_raw = ord("2");
var kb_a3_raw = ord("3");
var kb_ult_raw = ord("4");

var gp_jump_raw = gp_face1;
var gp_a1_raw = gp_face3;
var gp_a2_raw = gp_face2;
var gp_a3_raw = gp_face4;
var gp_duck_raw = gamepad_button_value(0, gp_shoulderrb); // R2
var gp_ult_raw  = gamepad_button_value(0, gp_shoulderlb); // L2

var cur_jump_kb = keyboard_check(kb_jump_raw);
var cur_duck_kb = keyboard_check(kb_duck_raw);
var cur_a1_kb   = keyboard_check(kb_a1_raw);
var cur_a2_kb   = keyboard_check(kb_a2_raw);
var cur_a3_kb   = keyboard_check(kb_a3_raw);
var cur_ult_kb  = keyboard_check(kb_ult_raw);

var cur_jump_gp = has_pad && gamepad_button_check(pad, gp_jump_raw);
var cur_duck_gp = has_pad && gamepad_button_check(pad, gp_duck_raw);
var cur_a1_gp   = has_pad && gamepad_button_check(pad, gp_a1_raw);
var cur_a2_gp   = has_pad && gamepad_button_check(pad, gp_a2_raw);
var cur_a3_gp   = has_pad && gamepad_button_check(pad, gp_a3_raw);
var cur_ult_gp  = has_pad && (gamepad_button_check(pad, gp_triggerleft) && gamepad_button_check(pad, gp_triggerright));

if (global.input_recorder.recording && script_exists(scr_chart_time)) {
    var now_t = scr_chart_time();
    if (now_t >= 0) {
        var push_event = function(_action, _variant, _device, _raw) {
            var sprinfo = scr_input_recorder_variant_sprite(_variant);
            var ev = {
                action: _action,
                variant: _variant,
                t_chart: now_t,
                device: _device,
                raw: _raw,
                pressed: true,
                spr: sprinfo.spr,
                anim: sprinfo.anim
            };
            array_push(global.input_recorder.events, ev);
        };

        if (cur_jump_kb && !prev_jump_kb) push_event("jump", "jump", "keyboard", kb_jump_raw);
        if (cur_duck_kb && !prev_duck_kb) push_event("duck", "duck", "keyboard", kb_duck_raw);
        if (cur_a1_kb   && !prev_a1_kb)   push_event("attack", "attack1", "keyboard", kb_a1_raw);
        if (cur_a2_kb   && !prev_a2_kb)   push_event("attack", "attack2", "keyboard", kb_a2_raw);
        if (cur_a3_kb   && !prev_a3_kb)   push_event("attack", "attack3", "keyboard", kb_a3_raw);
        if (cur_ult_kb  && !prev_ult_kb)  push_event("ultimate", "ultimate", "keyboard", kb_ult_raw);

        if (cur_jump_gp && !prev_jump_gp) push_event("jump", "jump", "gamepad", gp_jump_raw);
        if (cur_duck_gp && !prev_duck_gp) push_event("duck", "duck", "gamepad", gp_duck_raw);
        if (cur_a1_gp   && !prev_a1_gp)   push_event("attack", "attack1", "gamepad", gp_a1_raw);
        if (cur_a2_gp   && !prev_a2_gp)   push_event("attack", "attack2", "gamepad", gp_a2_raw);
        if (cur_a3_gp   && !prev_a3_gp)   push_event("attack", "attack3", "gamepad", gp_a3_raw);
        if (cur_ult_gp  && !prev_ult_gp)  push_event("ultimate", "ultimate", "gamepad", gp_ult_raw);
    }
}

prev_jump_kb = cur_jump_kb;
prev_duck_kb = cur_duck_kb;
prev_a1_kb   = cur_a1_kb;
prev_a2_kb   = cur_a2_kb;
prev_a3_kb   = cur_a3_kb;
prev_ult_kb  = cur_ult_kb;

prev_jump_gp = cur_jump_gp;
prev_duck_gp = cur_duck_gp;
prev_a1_gp   = cur_a1_gp;
prev_a2_gp   = cur_a2_gp;
prev_a3_gp   = cur_a3_gp;
prev_ult_gp  = cur_ult_gp;
