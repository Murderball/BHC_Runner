/// scr_autohit_reset()
/// Resets autoplay rearm state + clears transient "hit" flags on notes (editing-friendly)

function scr_autohit_reset()
{
    // Reset debounce memory
    global.auto_last_jump_t = -999999;
    global.auto_last_duck_t = -999999;
    global.auto_last_atk1_t = -999999;
    global.auto_last_atk2_t = -999999;
    global.auto_last_atk3_t = -999999;

    global.auto_prev_time_s = -999999;

    // If notes are not deleted on hit (hit-flag system), clear those flags so they can be rehittable
    if (variable_global_exists("chart") && !is_undefined(global.chart)) {
        var len = array_length(global.chart);
        for (var i = 0; i < len; i++) {
            var n = global.chart[i];
            if (is_struct(n)) {
                if (variable_struct_exists(n, "hit")) n.hit = false;
                if (variable_struct_exists(n, "hit_time")) n.hit_time = 0;
                if (variable_struct_exists(n, "hit_judge")) n.hit_judge = "";
            }
        }
    }
}
