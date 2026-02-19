/// scr_bg_cache_init()
/// Build sprite lookup caches once (near/far) for easy/normal/hard.
/// Uses global.BG_FRAMES (default 44 for 00..43).
/// No ternary, no undefined locals.

function scr_bg_cache_init()
{
    // Always rebuild safely if requested
    if (variable_global_exists("BG_CACHE_READY") && global.BG_CACHE_READY) return;

    global.BG_CACHE_READY = true;

    var N = 44;
    if (variable_global_exists("BG_FRAMES")) N = max(1, floor(global.BG_FRAMES));

    global.BG_CACHE_NEAR = array_create(3);
    global.BG_CACHE_FAR  = array_create(3);

    // difficulties by index
    // 0 easy, 1 normal, 2 hard
    for (var di = 0; di < 3; di++)
    {
        global.BG_CACHE_NEAR[di] = array_create(N, -1);
        global.BG_CACHE_FAR[di]  = array_create(N, -1);

        var diff_str = "easy";
        if (di == 1) diff_str = "normal";
        else if (di == 2) diff_str = "hard";

        for (var i = 0; i < N; i++)
        {
            var idx2 = string(i);
            if (i < 10) idx2 = "0" + idx2;

            var near_name = "spr_bg_" + diff_str + "_" + idx2;
            var far_name  = "spr_bg_far_" + diff_str + "_" + idx2;

            var near_spr = asset_get_index(near_name);
            global.BG_CACHE_NEAR[di][i] = near_spr;

            var far_spr = asset_get_index(far_name);
            if (far_spr == -1) far_spr = near_spr; // fallback to near
            global.BG_CACHE_FAR[di][i] = far_spr;
        }
    }
}