/// scr_time_to_beat(t)
function scr_time_to_beat(t)
{
    var spb = global.SEC_PER_BEAT;
    if (spb <= 0) spb = 0.001;

    var t0 = t;
    if (variable_global_exists("BEAT_ZERO_OFFSET_S")) t0 -= global.BEAT_ZERO_OFFSET_S;

    var denom = spb;
    if (denom == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom = 1;
    }
    return t0 / denom;
}
