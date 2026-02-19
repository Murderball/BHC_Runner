/// scr_bg_cache_init()
/// Build sprite lookup caches once (near/far) for easy/normal/hard.
/// LEVEL-AWARE:
/// - level03+: spr_bg_<diff>_00
/// - level01:  spr_bg_level1_<diff>_00   (and optional spr_bg_level1_far_<diff>_00)
/// Uses global.BG_FRAMES (Level 1 sets 9; Level 3 sets 44).
function scr_bg_cache_init()
{
    // Always rebuild safely if requested
    if (variable_global_exists("BG_CACHE_READY") && global.BG_CACHE_READY) return;

    global.BG_CACHE_READY = true;

    // Frame count
    var N = 44;
    if (variable_global_exists("BG_FRAMES")) N = max(1, floor(global.BG_FRAMES));

    // What level are we in?
    var lvl = "";
    if (variable_global_exists("LEVEL_KEY") && is_string(global.LEVEL_KEY)) lvl = global.LEVEL_KEY;

    // Build caches
    global.BG_CACHE_NEAR = array_create(3);
    global.BG_CACHE_FAR  = array_create(3);

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

            // -----------------------------
            // LEVEL-AWARE NAME BUILD
            // -----------------------------
            var near_name = "";
            var far_name  = "";

            if (lvl == "level01")
            {
                // Your naming scheme:
                // spr_bg_level1_hard_00 .. spr_bg_level1_hard_08
                near_name = "spr_bg_level1_" + diff_str + "_" + idx2;
                far_name  = "spr_bg_level1_far_" + diff_str + "_" + idx2; // optional
            }
            else
            {
                // Existing (Level 3) naming:
                near_name = "spr_bg_" + diff_str + "_" + idx2;
                far_name  = "spr_bg_far_" + diff_str + "_" + idx2;
            }

            // Resolve near
            var near_spr = asset_get_index(near_name);

            // If Level 1 only has HARD made so far, let easy/normal fall back to hard
            if (near_spr == -1 && lvl == "level01")
            {
                near_spr = asset_get_index("spr_bg_level1_hard_" + idx2);
            }

            // Final fallback to old sets (safety)
            if (near_spr == -1)
            {
                near_spr = asset_get_index("spr_bg_normal_00");
                if (near_spr == -1) near_spr = asset_get_index("spr_bg_easy_00");
            }

            global.BG_CACHE_NEAR[di][i] = near_spr;

            // Resolve far (optional; fall back to near)
            var far_spr = asset_get_index(far_name);

            if (far_spr == -1 && lvl == "level01")
            {
                // Optional far hard fallback if you ever add it
                far_spr = asset_get_index("spr_bg_level1_far_hard_" + idx2);
            }

            if (far_spr == -1) far_spr = near_spr;
            global.BG_CACHE_FAR[di][i] = far_spr;
        }
    }
}
