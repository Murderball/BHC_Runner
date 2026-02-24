function scr_recorder_quantize_to_eighth(t, bpm)
{
    var _bpm = max(1.0, real(bpm));
    var denom_bpm = _bpm;
if (denom_bpm == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_bpm = 1;
}
var beat_duration = 60.0 / denom_bpm;
    var eighth_duration = beat_duration * 0.5;

    var denom_eighth = eighth_duration;
if (denom_eighth == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_eighth = 1;
}
var grid8 = round(max(0.0, t) / denom_eighth);
    var grid_time = grid8 * eighth_duration;
    var err = abs(real(t) - grid_time);

    return {
        grid8: grid8,
        grid_time: grid_time,
        err: err
    };
}
