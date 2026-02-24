function scr_editor_snap_time(time_sec) {
    var denom_spb = global.SEC_PER_BEAT;
if (denom_spb == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_spb = 1;
}
var beat = time_sec / denom_spb;
    var denom_snap = global.editor_snap;
if (denom_snap == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_snap = 1;
}
beat = round(beat / denom_snap) * global.editor_snap;
    return max(0, beat * global.SEC_PER_BEAT);
}
