/// scr_bg_debug_reverse_init()
/// Builds ds_maps that map sprite asset -> readable label like "easy_07" or "hard_44"
/// so we can debug without asset_get_name().

function scr_bg_debug_reverse_init()
{
    if (variable_global_exists("BG_DBG_REV_READY") && global.BG_DBG_REV_READY) return;
    global.BG_DBG_REV_READY = true;

    // Ensure BG cache exists
    if (!variable_global_exists("BG_CACHE_READY") || !global.BG_CACHE_READY)
    {
        if (script_exists(scr_bg_cache_init)) scr_bg_cache_init();
    }

    // Create maps
    if (variable_global_exists("bg_dbg_rev_near") && ds_exists(global.bg_dbg_rev_near, ds_type_map))
        ds_map_destroy(global.bg_dbg_rev_near);
    if (variable_global_exists("bg_dbg_rev_far") && ds_exists(global.bg_dbg_rev_far, ds_type_map))
        ds_map_destroy(global.bg_dbg_rev_far);

    global.bg_dbg_rev_near = ds_map_create();
    global.bg_dbg_rev_far  = ds_map_create();

    var diffs = ["easy","normal","hard"];

    for (var di = 0; di < 3; di++)
    {
        var N = (variable_global_exists("BG_FRAMES") ? global.BG_FRAMES : 45);
for (var i = 0; i < N; i++)
        {
            var sprN = global.BG_CACHE_NEAR[di][i];
            var sprF = global.BG_CACHE_FAR[di][i];

            var label = diffs[di] + "_" + ((i < 10) ? ("0" + string(i)) : string(i));

            if (sprN != -1) ds_map_replace(global.bg_dbg_rev_near, sprN, label);
            if (sprF != -1) ds_map_replace(global.bg_dbg_rev_far,  sprF, label);
        }
    }
}