/// scr_note_screen_x(note_time, [now_time_override])
/// Convert a timeline time to GUI X.
///
/// - If now_time_override is provided (real), it is used (editor / queries).
/// - Otherwise it uses scr_chart_time() (play) or global.editor_time (editor).
///
/// Safe against undefined globals / startup frames.
function scr_note_screen_x(note_time, now_time_override)
{
    // If caller passes bad time, just put it far right (offscreen)
    if (!is_real(note_time)) return display_get_gui_width() + 9999;

    // HIT X default
    var hitx = 448;
    if (variable_global_exists("HIT_X_GUI") && is_real(global.HIT_X_GUI)) hitx = global.HIT_X_GUI;

    // PPS default
    var pps_val = 0;
    if (script_exists(scr_timeline_pps)) pps_val = scr_timeline_pps();
    if (!is_real(pps_val) || pps_val == 0)
{
    if (variable_global_exists("CHART_PPS") && is_real(global.CHART_PPS) && global.CHART_PPS != 0) pps_val = global.CHART_PPS;
    else if (variable_global_exists("WORLD_PPS") && is_real(global.WORLD_PPS) && global.WORLD_PPS != 0) pps_val = global.WORLD_PPS;
    else pps_val = 1;
}

    if (!is_real(pps_val) || pps_val == 0) pps_val = 1;

    // NOW time (override if provided)
    var now_time = 0;

    if (is_real(now_time_override)) {
        now_time = now_time_override;
    } else if (script_exists(scr_chart_time)) {
        now_time = scr_chart_time();
    } else if (variable_global_exists("editor_time") && is_real(global.editor_time)) {
        now_time = global.editor_time;
    }

    if (!is_real(now_time)) now_time = 0;

    return hitx + (note_time - now_time) * pps_val;
}
