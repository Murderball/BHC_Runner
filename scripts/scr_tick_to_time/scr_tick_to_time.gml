function scr_tick_to_time(tick_i) {
    // Convert integer ticks -> seconds
    var beats = tick_i / global.TICKS_PER_BEAT;
    return beats * global.SEC_PER_BEAT;
}
