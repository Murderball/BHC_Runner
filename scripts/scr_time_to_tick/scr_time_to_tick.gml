function scr_time_to_tick(time_sec) {
    // Convert seconds -> integer ticks (1 tick = 1/16 beat)
    var denom = global.SEC_PER_BEAT;
    if (denom == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom = 1;
    }
    var beats = time_sec / denom;
    return round(beats * global.TICKS_PER_BEAT);
}
