/// obj_input_recorder_machine : Create
recording_enabled = false;
current_take = [];
take_start_time = 0.0;
prev_chart_time = -1.0;

if (!variable_global_exists("recorder_take_index")) global.recorder_take_index = 1;
if (!variable_global_exists("recorder_last_take_path")) global.recorder_last_take_path = "";
