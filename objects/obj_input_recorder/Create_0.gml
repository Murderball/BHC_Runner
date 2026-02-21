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

ui_x = 80;
ui_y = 120;
ui_w = 120;
ui_h = 40;
ui_gap = 10;

box_labels = ["jump", "duck", "atk1", "atk2", "atk3", "ult"];

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
