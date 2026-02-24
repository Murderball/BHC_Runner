function scr_bar_s() {
    // seconds per bar (supports simple time sig; assumes quarter-note beat when denom=4)
    var bpm = global.BPM;
    if (bpm <= 0) bpm = 120;

    var beats_per_bar = global.TIME_SIG_NUM; // e.g., 4
    var _bpm_denom = bpm;
    if (_bpm_denom == 0) {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        _bpm_denom = 1;
    }
    var beat_s = 60.0 / _bpm_denom;                 // quarter-note beat

    return beats_per_bar * beat_s;           // bar duration
}

function scr_bar_index_at_time(t_s) {
    var bar_s = scr_bar_s();
    if (bar_s <= 0) return 0;
    var _bar_denom = bar_s;
    if (_bar_denom == 0) {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        _bar_denom = 1;
    }
    return floor(t_s / _bar_denom);
}

function scr_time_at_bar_index(bar_i) {
    return bar_i * scr_bar_s();
}
