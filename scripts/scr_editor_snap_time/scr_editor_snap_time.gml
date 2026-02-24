function scr_editor_snap_time(time_sec) {
    var _spb_denom = global.SEC_PER_BEAT;
    if (_spb_denom == 0) {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        _spb_denom = 1;
    }
    var beat = time_sec / _spb_denom;
    var _snap_denom = global.editor_snap;
    if (_snap_denom == 0) {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        _snap_denom = 1;
    }
    beat = round(beat / _snap_denom) * global.editor_snap;
    return max(0, beat * global.SEC_PER_BEAT);
}
