function scr_tick_to_time(tick_i) {
    // Convert integer ticks -> seconds
    var denom = global.TICKS_PER_BEAT;
    if (denom == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom = 1;
    }
    var beats = tick_i / denom;
    return beats * global.SEC_PER_BEAT;
}
