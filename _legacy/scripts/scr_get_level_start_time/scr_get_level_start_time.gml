/// scr_get_level_start_time() -> real
/// Returns the forced start time in seconds (>=0), or 0 if none.
/// If LEVEL_START_OVERRIDE_ONCE is true, clears override after use.

function scr_get_level_start_time()
{
    var t = 0.0;

    if (variable_global_exists("LEVEL_START_OVERRIDE_S")
    && is_real(global.LEVEL_START_OVERRIDE_S)
    && global.LEVEL_START_OVERRIDE_S >= 0.0)
    {
        t = global.LEVEL_START_OVERRIDE_S;

        if (variable_global_exists("LEVEL_START_OVERRIDE_ONCE") && global.LEVEL_START_OVERRIDE_ONCE)
        {
            global.LEVEL_START_OVERRIDE_S = -1.0;
        }
    }

    return t;
}
