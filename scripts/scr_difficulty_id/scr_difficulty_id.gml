/// scr_difficulty_id() -> 0 easy, 1 normal, 2 hard
function scr_difficulty_id()
{
    var d = 1;
    if (variable_global_exists("DIFFICULTY")) d = global.DIFFICULTY;
    else if (variable_global_exists("diff")) d = global.diff;

    if (!is_real(d)) d = 1;
    return clamp(floor(d), 0, 2);
}
