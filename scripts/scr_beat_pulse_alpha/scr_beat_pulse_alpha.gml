/// scr_beat_pulse_alpha(bpm, t, strength)
/// Returns alpha multiplier (0..1) with a fast-on, decay pulse each beat.
function scr_beat_pulse_alpha(bpm, t, strength)
{
    var bpm_use = is_real(bpm) && bpm > 0 ? bpm : 140;
    var t_use = is_real(t) ? t : 0.0;
    var str = is_real(strength) ? strength : 0.45;

    var denom = bpm_use;
    if (denom == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom = 1;
    }
    var beat = 60.0 / denom;
    if (beat <= 0) return 0.35;

    var denom_phase = beat;
    if (denom_phase == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_phase = 1;
    }
    var phase = frac(t_use / denom_phase);

    // Higher k = sharper attack and quicker decay.
    var k = 5.0;
    if (variable_global_exists("PROGRESS_PULSE_K") && is_real(global.PROGRESS_PULSE_K))
        k = max(1.0, global.PROGRESS_PULSE_K);

    var pulse = power(1.0 - phase, k);
    return clamp(0.35 + str * pulse, 0.0, 1.0);
}
