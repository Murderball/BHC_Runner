function scr_bg_prewarm_start(_diffStr)
{
    // Build the queue once
    global.bg_prewarm_queue = [];
    global.bg_prewarm_i = 0;
    global.bg_prewarm_done = false;
// IMPORTANT: init handle
    global.bg_prewarm_surf = -1;
    // Ensure cache exists
    if (!variable_global_exists("BG_CACHE_READY") || !global.BG_CACHE_READY) {
        if (script_exists(scr_bg_cache_init)) scr_bg_cache_init();
    }

    // Map diff string to cache index
    var d = string_lower(string(_diffStr));
    var di = 1;
    if (d == "easy") di = 0;
    else if (d == "hard") di = 2;

    // Only prewarm CURRENT difficulty (not all 3)
    var nearArr = global.BG_CACHE_NEAR[di];
    var farArr  = global.BG_CACHE_FAR[di];

    var N = array_length(nearArr);
    for (var i = 0; i < N; i++) {
        var sn = nearArr[i];
        var sf = farArr[i];
        if (sn != -1) array_push(global.bg_prewarm_queue, sn);
        if (sf != -1) array_push(global.bg_prewarm_queue, sf);
    }
}
