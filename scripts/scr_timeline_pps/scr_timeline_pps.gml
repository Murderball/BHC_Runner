/// scr_timeline_pps()
/// Returns scroll speed in pixels/second for chart rendering.
/// Boss-room-only: uses PX_PER_BEAT * (chart_bpm/60) if available.
/// Everywhere else: uses global.WORLD_PPS (your baseline).

function scr_timeline_pps()
{
    // Boss room override
    if (variable_global_exists("LEVEL_MODE") && global.LEVEL_MODE == "boss"
        && variable_global_exists("BOSS_ROOM") && room == global.BOSS_ROOM)
    {
        // Default pixels-per-beat (visual spacing)
        if (!variable_global_exists("PX_PER_BEAT") || !is_real(global.PX_PER_BEAT) || global.PX_PER_BEAT <= 0)
            global.PX_PER_BEAT = 192;

        var bpm = 140;
        if (variable_global_exists("chart_bpm") && is_real(global.chart_bpm)) bpm = global.chart_bpm;
        else if (variable_global_exists("BPM") && is_real(global.BPM)) bpm = global.BPM;

        return global.PX_PER_BEAT * (bpm / 60.0);
    }

    // Normal gameplay
    if (variable_global_exists("WORLD_PPS") && is_real(global.WORLD_PPS) && global.WORLD_PPS != 0) return global.WORLD_PPS;

    return 1;
}
