/// scr_difficulty_update()
function scr_difficulty_update()
{
    // Don't run during editor
    if (global.editor_on) return;

    if (!is_array(global.diff_events) || array_length(global.diff_events) <= 0) return;

    // Only trigger if song is actually playing
    if (!global.song_playing || global.song_handle < 0) return;

    var t_now = scr_song_time();
    if (!is_real(t_now) || is_nan(t_now)) return;

    // Find next non-done event
    var n = array_length(global.diff_events);
    var next_i = -1;
    for (var i = 0; i < n; i++) {
        if (!global.diff_events[i].done) { next_i = i; break; }
    }
    if (next_i < 0) return;

    var ev = global.diff_events[next_i];

    // Trigger
    if (t_now >= ev.t)
    {
        // Pull swap flags (fallback to globals if older events don't have the fields yet)
        var sv = (is_struct(ev) && variable_struct_exists(ev, "swap_visual")) ? ev.swap_visual : global.diff_swap_visual;
        var sa = (is_struct(ev) && variable_struct_exists(ev, "swap_audio"))  ? ev.swap_audio  : global.diff_swap_audio;

        // Apply with per-event flags
        // NOTE: You must update scr_apply_difficulty to accept these two args (see below)
        scr_apply_difficulty(ev.diff, "marker@" + string(ev.t), sv, sa);

        global.diff_events[next_i].done = true;
    }
}