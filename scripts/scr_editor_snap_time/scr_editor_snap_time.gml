function scr_editor_snap_time(time_sec) {
    var beat = time_sec / global.SEC_PER_BEAT;
    beat = round(beat / global.editor_snap) * global.editor_snap;
    return max(0, beat * global.SEC_PER_BEAT);
}
