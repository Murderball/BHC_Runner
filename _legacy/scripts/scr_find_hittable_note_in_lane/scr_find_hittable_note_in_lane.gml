/// scr_find_hittable_note_in_lane(lane, now_s, window_s)
/// Supports either global.notes as ds_list OR as array.
/// Returns index (array index or ds_list index), or -1.
function scr_find_hittable_note_in_lane(_lane, _now_s, _window_s)
{
    var best_i = -1;
    var best_dt = 999999;

    // --- ds_list version ---
    if (is_ds_list(global.notes))
    {
        var ncount = ds_list_size(global.notes);
        for (var i = 0; i < ncount; i++)
        {
            var n = global.notes[| i];

            if (n.hit) continue;
            if (n.lane != _lane) continue;

            var dt = abs(n.t - _now_s);
            if (dt <= _window_s && dt < best_dt)
            {
                best_dt = dt;
                best_i = i;
            }
        }
        return best_i;
    }

    // --- array version ---
    var ncount2 = array_length(global.notes);
    for (var j = 0; j < ncount2; j++)
    {
        var n2 = global.notes[j];

        if (n2.hit) continue;
        if (n2.lane != _lane) continue;

        var dt2 = abs(n2.t - _now_s);
        if (dt2 <= _window_s && dt2 < best_dt)
        {
            best_dt = dt2;
            best_i = j;
        }
    }
    return best_i;
}
