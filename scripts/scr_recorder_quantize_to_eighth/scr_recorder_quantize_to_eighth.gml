function scr_recorder_quantize_to_eighth(t, bpm)
{
    var _bpm = max(1.0, real(bpm));
    var beat_duration = 60.0 / _bpm;
    var eighth_duration = beat_duration * 0.5;

    var grid8 = round(max(0.0, t) / eighth_duration);
    var grid_time = grid8 * eighth_duration;
    var err = abs(real(t) - grid_time);

    return {
        grid8: grid8,
        grid_time: grid_time,
        err: err
    };
}
