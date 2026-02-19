/// scr_chart_time()
/// Chart "now" time used for drawing + hit logic.
/// Positive CHART_TIME_OFFSET_S = chart later (notes reach hitline later).

function scr_chart_time()
{
    var base = 0.0;

    // Editor time wins
    if (variable_global_exists("editor_on") && global.editor_on)
    {
        if (variable_global_exists("editor_time") && !is_undefined(global.editor_time))
            base = global.editor_time;
        else
            base = 0.0;
    }
    else
    {
        // -----------------------------
        // BOSS ROOM OVERRIDE (ONLY)
        // -----------------------------
        var in_boss_room = false;

        if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss"
            && variable_global_exists("BOSS_ROOM") && room == global.BOSS_ROOM)
        {
            in_boss_room = true;
        }

        if (in_boss_room && variable_global_exists("BOSS_TIMELINE_S") && is_real(global.BOSS_TIMELINE_S))
        {
            base = global.BOSS_TIMELINE_S;
        }
        else
        {
            // Normal gameplay time from song
            base = scr_song_time();
            if (is_undefined(base)) base = 0.0;
        }
    }

    var off = 0.0;
    if (variable_global_exists("CHART_TIME_OFFSET_S") && !is_undefined(global.CHART_TIME_OFFSET_S))
        off = global.CHART_TIME_OFFSET_S;

    return base - off;
}
