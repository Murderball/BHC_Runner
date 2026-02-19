function scr_time_to_tick(time_sec) {
    // Convert seconds -> integer ticks (1 tick = 1/16 beat)
    var beats = time_sec / global.SEC_PER_BEAT;
    return round(beats * global.TICKS_PER_BEAT);
}
