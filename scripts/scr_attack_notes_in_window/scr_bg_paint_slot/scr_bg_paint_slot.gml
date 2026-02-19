/// scr_bg_paint_slot(slot, chunk_or_ci)
/// Paint background sprite IDs for a slot.
/// Uses global chunk index (ci) to pick frame: idx = ci mod 45
/// Uses stable integer difficulty: global.bg_diff_i (0 easy, 1 normal, 2 hard)
/// No ternary operator.

function scr_bg_paint_slot(_slot, _chunk_or_ci)
{
    if (!variable_global_exists("bg_slot_near") || !is_array(global.bg_slot_near)) return;
    if (!variable_global_exists("bg_slot_far")  || !is_array(global.bg_slot_far))  return;

    if (_slot < 0) return;
    if (_slot >= array_length(global.bg_slot_near)) return;
// --- duplicate guard: if this slot already painted this ci, skip ---
if (!variable_global_exists("bg_slot_last_ci") || !is_array(global.bg_slot_last_ci)
    || array_length(global.bg_slot_last_ci) != array_length(global.bg_slot_near))
{
    global.bg_slot_last_ci = array_create(array_length(global.bg_slot_near), -999999);
}

if (is_real(_chunk_or_ci))
{
    var ci_now = floor(_chunk_or_ci);

    if (global.bg_slot_last_ci[_slot] == ci_now)
        return; // already painted this ci for this slot

    global.bg_slot_last_ci[_slot] = ci_now;
}
else
{
    // For string calls, don't guard (rare) — or you can parse like ci if you want.
}
    // Ensure cache exists
    if (!variable_global_exists("BG_CACHE_READY") || !global.BG_CACHE_READY)
    {
        if (script_exists(scr_bg_cache_init)) scr_bg_cache_init();
    }

    // Stable difficulty index
    var di = 1; // default normal
    if (variable_global_exists("bg_diff_i")) di = global.bg_diff_i;
    if (!is_real(di)) di = 1;
    di = floor(di);
    if (di < 0 || di > 2) di = 1;

    // Decide bg index 0..44
    var idx = 0;

    if (is_real(_chunk_or_ci))
    {
        idx = floor(_chunk_or_ci);
    }
    else
    {
        // Fallback: parse trailing "_NN" from string
        var n = string(_chunk_or_ci);
        var p = string_last_pos("_", n);
        var suffix = "00";

        if (p > 0) suffix = string_copy(n, p + 1, string_length(n) - p);
        else       suffix = n;

        idx = floor(real(suffix));
        if (!is_real(idx)) idx = 0;
    }

var N = (variable_global_exists("BG_FRAMES") ? global.BG_FRAMES : 45);

idx = idx mod N;
if (idx < 0) idx += N;

    // Pull from cache
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

    // Fallback sprite (prefer normal_00)
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

    // Optional debug label per slot
    if (!variable_global_exists("bg_slot_dbg") || !is_array(global.bg_slot_dbg))
        global.bg_slot_dbg = array_create(array_length(global.bg_slot_near), "");

    if (_slot < array_length(global.bg_slot_dbg))
    {
        var idx2 = string(idx);
        if (idx < 10) idx2 = "0" + idx2;

        var diff_str = "normal";
        if (di == 0) diff_str = "easy";
        else if (di == 2) diff_str = "hard";

        global.bg_slot_dbg[_slot] = diff_str + "_" + idx2 + " (from " + string(_chunk_or_ci) + ")";
    }
}