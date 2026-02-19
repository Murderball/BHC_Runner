/// scr_chart_clear()
/// Clears the CURRENT chart ONLY if it is the boss chart.

function scr_chart_clear()
{
    // Must have a chart loaded
    if (!variable_global_exists("chart") || !is_array(global.chart)) return;

    // Must be the boss chart
    if (!variable_global_exists("chart_file")) return;
    if (global.chart_file != global.BOSS_CHART_FILE) {
        show_debug_message("[CHART CLEAR] Ignored (not boss chart): " + string(global.chart_file));
        return;
    }

    // Clear boss chart
    global.chart = [];

    // Reset editor state
    if (variable_global_exists("editor_sel"))  global.editor_sel = -1;
    if (variable_global_exists("editor_drag")) global.editor_drag = false;

    show_debug_message("[CHART CLEAR] Boss chart cleared");
}
