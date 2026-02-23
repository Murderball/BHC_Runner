function scr_time_camera_left() {
    // camera-left time (the "now" at the left edge of the view)
    var t = global.editor_on ? global.editor_time : scr_song_time();
    return max(0, t + global.MASTER_TIME_OFFSET_S);
}

