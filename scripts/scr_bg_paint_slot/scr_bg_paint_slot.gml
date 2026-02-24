/// scr_bg_paint_slot(slot, chunk_or_ci)
/// Paint background sprite IDs for a slot.
/// Uses stable integer difficulty: global.bg_diff_i (0 easy, 1 normal, 2 hard)
/// NEW: BG_TIME_SHIFT_S shifts background timing (in seconds) without affecting gameplay.
/// No ternary operator.

function scr_bg_paint_slot(_slot, _chunk_or_ci)
{
    var __mp = (script_exists(scr_microprof_begin) ? scr_microprof_begin("bg.paint_slot") : 0);

    if (!variable_global_exists("bg_slot_near") || !is_array(global.bg_slot_near)) {
        if (script_exists(scr_microprof_end)) scr_microprof_end("bg.paint_slot", __mp);
        return;
    }
    if (!variable_global_exists("bg_slot_far")  || !is_array(global.bg_slot_far)) {
        if (script_exists(scr_microprof_end)) scr_microprof_end("bg.paint_slot", __mp);
        return;
    }

    if (_slot < 0) {
        if (script_exists(scr_microprof_end)) scr_microprof_end("bg.paint_slot", __mp);
        return;
    }
    if (_slot >= array_length(global.bg_slot_near)) {
        if (script_exists(scr_microprof_end)) scr_microprof_end("bg.paint_slot", __mp);
        return;
    }

    // ----------------------------------------------------
    // Duplicate guard array
    // ----------------------------------------------------
    if (!variable_global_exists("bg_slot_last_ci") || !is_array(global.bg_slot_last_ci)
        || array_length(global.bg_slot_last_ci) != array_length(global.bg_slot_near))
    {
        global.bg_slot_last_ci = array_create(array_length(global.bg_slot_near), -999999);
    }

    // ----------------------------------------------------
    // BG time nudge (seconds)
    // ----------------------------------------------------
    var bg_shift_s = 0.0;
    if (variable_global_exists("BG_TIME_SHIFT_S")) bg_shift_s = global.BG_TIME_SHIFT_S;
    if (!is_real(bg_shift_s) || is_nan(bg_shift_s)) bg_shift_s = 0.0;

    // ----------------------------------------------------
    // If numeric ci, apply duplicate guard (self-heal if fallback)
    // ----------------------------------------------------
    var ci_now = 0;
    var have_ci = false;

    if (is_real(_chunk_or_ci))
    {
        ci_now = floor(_chunk_or_ci);
        have_ci = true;

        // If this slot already painted this ci, normally skip...
        // BUT if it is currently showing the fallback sprite, allow repaint to self-heal.
        if (global.bg_slot_last_ci[_slot] == ci_now)
        {
            var fb0 = -1;
            if (variable_global_exists("bg_fallback_sprite")) fb0 = global.bg_fallback_sprite;
            if (fb0 == -1) fb0 = asset_get_index("spr_bg_normal_00");
            if (fb0 == -1) fb0 = asset_get_index("spr_bg_easy_00");

            // if it's NOT fallback, keep the fast early-exit
            if (global.bg_slot_near[_slot] != fb0) {
                if (script_exists(scr_microprof_end)) scr_microprof_end("bg.paint_slot", __mp);
                return;
            }
            // else: fall through and repaint
        }

        global.bg_slot_last_ci[_slot] = ci_now;
    }
    else
    {
        // For string calls, don't guard (rare) — or you can parse to ci if desired.
    }

    // ----------------------------------------------------
    // Ensure cache exists
    // ----------------------------------------------------
    if (!variable_global_exists("BG_CACHE_READY") || !global.BG_CACHE_READY)
    {
        if (script_exists(scr_bg_cache_init)) scr_bg_cache_init();
    }

    // ----------------------------------------------------
    // Stable difficulty index
    // ----------------------------------------------------
    var di = 1; // default normal
    if (variable_global_exists("bg_diff_i")) di = global.bg_diff_i;
    if (!is_real(di) || is_nan(di)) di = 1;
    di = floor(di);
    if (di < 0 || di > 2) di = 1;

    // ----------------------------------------------------
    // Decide bg index 0..N-1
    // ----------------------------------------------------
    var N = 45;
    if (variable_global_exists("BG_FRAMES")) N = global.BG_FRAMES;
    if (!is_real(N) || is_nan(N)) N = 45;
    N = floor(N);
    if (N <= 0) N = 45;

    var idx = 0;

    if (have_ci)
    {
        // Convert CI -> time, apply BG shift, convert back to BG-frame index.
        // This shifts the BG without moving chunks/spawn/hitline.
        var pps = 1.0;
        if (variable_global_exists("WORLD_PPS") && is_real(global.WORLD_PPS) && !is_nan(global.WORLD_PPS)) pps = global.WORLD_PPS;
        if (pps <= 0) pps = 1.0;

        var chunk_w_px = global.CHUNK_W_TILES * global.TILE_W;
        if (!is_real(chunk_w_px) || is_nan(chunk_w_px) || chunk_w_px <= 0) chunk_w_px = 1.0;

        // Time at start of this CI (unshifted)
        var t_ci = (ci_now * chunk_w_px) / pps;

        // Apply nudge (positive shift = BG advances earlier/later depending on your design)
        var t_bg = t_ci + bg_shift_s;

        // Convert back to a "ci-like" index for frame selection
        var ci_bg = floor((t_bg * pps) / chunk_w_px);

        idx = ci_bg mod N;
        if (idx < 0) idx += N;
    }
    else
    {
        // String fallback: parse trailing "_NN"
        var n = string(_chunk_or_ci);
        var p = string_last_pos("_", n);
        var suffix = "00";

        if (p > 0) suffix = string_copy(n, p + 1, string_length(n) - p);
        else       suffix = n;

        idx = floor(real(suffix));
        if (!is_real(idx) || is_nan(idx)) idx = 0;

        idx = idx mod N;
        if (idx < 0) idx += N;
    }

    // ----------------------------------------------------
    // Pull from cache
    // ----------------------------------------------------
    var sprN = -1;
    var sprF = -1;

    if (variable_global_exists("BG_CACHE_NEAR") && is_array(global.BG_CACHE_NEAR))
    {
        if (di < array_length(global.BG_CACHE_NEAR))
        {
            var arrN = global.BG_CACHE_NEAR[di];
            if (is_array(arrN) && idx < array_length(arrN)) sprN = arrN[idx];
        }
    }

    if (variable_global_exists("BG_CACHE_FAR") && is_array(global.BG_CACHE_FAR))
    {
        if (di < array_length(global.BG_CACHE_FAR))
        {
            var arrF = global.BG_CACHE_FAR[di];
            if (is_array(arrF) && idx < array_length(arrF)) sprF = arrF[idx];
        }
    }

    // ----------------------------------------------------
    // Fallback sprite (prefer normal_00)
    // ----------------------------------------------------
    var fb = -1;
    if (variable_global_exists("bg_fallback_sprite")) fb = global.bg_fallback_sprite;
    if (fb == -1) fb = asset_get_index("spr_bg_normal_00");
    if (fb == -1) fb = asset_get_index("spr_bg_easy_00");

    if (sprN == -1)
    {
        if (variable_global_exists("dbg_bg_hit") && global.dbg_bg_hit)
            show_debug_message("[BG FALLBACK] slot=" + string(_slot) + " idx=" + string(idx) + " di=" + string(di));
        sprN = fb;
    }
    if (sprF == -1) sprF = sprN;

    global.bg_slot_near[_slot] = sprN;
    global.bg_slot_far[_slot]  = sprF;

    // ----------------------------------------------------
    // Optional debug label per slot
    // ----------------------------------------------------
    if (!variable_global_exists("bg_slot_dbg") || !is_array(global.bg_slot_dbg))
        global.bg_slot_dbg = array_create(array_length(global.bg_slot_near), "");

    if (_slot < array_length(global.bg_slot_dbg))
    {
        var idx2 = string(idx);
        if (idx < 10) idx2 = "0" + idx2;

        var diff_str = "normal";
        if (di == 0) diff_str = "easy";
        else if (di == 2) diff_str = "hard";

        var src = string(_chunk_or_ci);
        if (have_ci) src = "ci=" + string(ci_now) + " shift_s=" + string(bg_shift_s);

        global.bg_slot_dbg[_slot] = diff_str + "_" + idx2 + " (" + src + ")";
    }

    if (script_exists(scr_microprof_end)) scr_microprof_end("bg.paint_slot", __mp);
}
