/// scr_autohit_enabled() -> bool
function scr_autohit_enabled()
{
    return variable_global_exists("AUTO_HIT_ENABLED") && (global.AUTO_HIT_ENABLED == true);
}
