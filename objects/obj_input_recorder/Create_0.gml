/// obj_input_recorder : Create

if (!variable_global_exists("input_recorder") || !is_struct(global.input_recorder)) {
    global.input_recorder = {
        enabled: true,
        recording: false,
        events: [],
        clear: function() { events = []; },
        start: function() { recording = true; },
        stop: function() { recording = false; }
    };
}

editor_mode = (variable_global_exists("editor_on") && global.editor_on);

ui_x = 24;
ui_y = 24;
ui_w = 110;
ui_h = 44;
ui_gap = 8;

box_labels = ["JUMP", "DUCK", "ATK1", "ATK2", "ATK3", "ULT"];

prev_jump_kb = false;
prev_duck_kb = false;
prev_a1_kb   = false;
prev_a2_kb   = false;
prev_a3_kb   = false;
prev_ult_kb  = false;

prev_jump_gp = false;
prev_duck_gp = false;
prev_a1_gp   = false;
prev_a2_gp   = false;
prev_a3_gp   = false;
prev_ult_gp  = false;
