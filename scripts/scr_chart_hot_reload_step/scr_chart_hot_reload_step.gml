function scr_chart_hot_reload_step()
{
    if (!variable_global_exists("chart_hot_reload") || !global.chart_hot_reload) return;

    // Only hot-reload if we have a known loaded path
    if (!variable_global_exists("chart_loaded_path")) return;

    // Don't hot-reload datafiles (included files don't change at runtime)
    if (variable_global_exists("chart_loaded_from_datafiles") && global.chart_loaded_from_datafiles) return;

    // Throttle checks
    var hz = 4;
    if (variable_global_exists("chart_hot_reload_hz")) hz = max(1, global.chart_hot_reload_hz);

    global._chart_hot_reload_accum += delta_time / 1000000.0; // seconds
    var denom_hz = hz;
if (denom_hz == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_hz = 1;
}
var interval = 1.0 / denom_hz;
    if (global._chart_hot_reload_accum < interval) return;
    global._chart_hot_reload_accum = 0;

    var path = global.chart_loaded_path;

    // If file vanished, do nothing (avoid nuking chart mid-session)
    if (!file_exists(path)) return;

        // Compare file signature (GM runtime-safe)
    var sig = file_size(path);

    // Initialize baseline if needed
    if (!variable_global_exists("_chart_hot_reload_last_sig") || global._chart_hot_reload_last_sig == -1) {
        global._chart_hot_reload_last_sig = sig;
        return;
    }

    // If changed, reload
    if (sig != global._chart_hot_reload_last_sig) {
        global._chart_hot_reload_last_sig = sig;

        show_debug_message("[HOT RELOAD] Chart changed -> reloading: " + string(path));

        // Reload chart
        scr_chart_load();

        // Clear selection to avoid stale indices
        if (variable_global_exists("sel")) global.sel = [];
    }
}
