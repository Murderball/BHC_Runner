/// scr_bg_prewarm_textures()
/// Forces background sprites to be uploaded/ready on the GPU before gameplay.
/// Updated to respect global.BG_FRAMES / cache length (00..43 by default).
/// No ternary.

function scr_bg_prewarm_textures()
{
    if (variable_global_exists("BG_PREWARM_DONE") && global.BG_PREWARM_DONE) return;
    global.BG_PREWARM_DONE = true;

    // Ensure cache exists
    if (!variable_global_exists("BG_CACHE_READY") || !global.BG_CACHE_READY)
    {
        if (script_exists(scr_bg_cache_init)) scr_bg_cache_init();
    }

    // Determine frame count
    var N = 44;
    if (variable_global_exists("BG_FRAMES")) N = max(1, floor(global.BG_FRAMES));

    // If cache exists, trust its length more than BG_FRAMES
    if (variable_global_exists("BG_CACHE_NEAR") && is_array(global.BG_CACHE_NEAR))
    {
        if (array_length(global.BG_CACHE_NEAR) >= 1 && is_array(global.BG_CACHE_NEAR[0]))
        {
            N = array_length(global.BG_CACHE_NEAR[0]);
        }
    }

    // Make a tiny surface and draw everything once
    var s = surface_create(64, 64);
    if (!surface_exists(s)) return;

    surface_set_target(s);
    draw_clear_alpha(c_black, 0);

    for (var di = 0; di < 3; di++)
    {
        // Guard per-diff array existence
        var arrN = (variable_global_exists("BG_CACHE_NEAR") && is_array(global.BG_CACHE_NEAR) && di < array_length(global.BG_CACHE_NEAR)) ? global.BG_CACHE_NEAR[di] : [];
        var arrF = (variable_global_exists("BG_CACHE_FAR")  && is_array(global.BG_CACHE_FAR)  && di < array_length(global.BG_CACHE_FAR))  ? global.BG_CACHE_FAR[di]  : [];

        var NN = N;
        if (is_array(arrN)) NN = min(NN, array_length(arrN));
        if (is_array(arrF)) NN = min(NN, array_length(arrF));

        for (var i = 0; i < NN; i++)
        {
            var sprN = -1;
            var sprF = -1;

            if (is_array(arrN) && i < array_length(arrN)) sprN = arrN[i];
            if (is_array(arrF) && i < array_length(arrF)) sprF = arrF[i];

            if (sprN != -1) draw_sprite(sprN, 0, 0, 0);
            if (sprF != -1) draw_sprite(sprF, 0, 0, 0);
        }
    }

    surface_reset_target();
    surface_free(s);
}