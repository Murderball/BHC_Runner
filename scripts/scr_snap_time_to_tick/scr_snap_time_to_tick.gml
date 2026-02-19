function scr_snap_time_to_tick(time_sec) {
    // If snap is off, return original time
    if (!global.editor_snap_on) return max(0, time_sec);

    // Snap to nearest tick (1/16 note)
    var tick_i = scr_time_to_tick(time_sec);
    return scr_tick_to_time(tick_i);
}
