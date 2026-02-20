/// scr_set_difficulty_visuals(diff)
/// Shows only one visual layer; keeps collide always active.
/// IMPORTANT: In rm_level01, Normal/Easy visual layers have no tileset (tilemap id = -1),
/// so we must fall back to a valid layer (Hard) if the requested one doesn't exist.

function scr_set_difficulty_visuals(diff)
{
    var d = string_lower(string(diff));
    d = string_replace_all(d, " ", ""); // robust normalize

    // Desired flags
    var want_easy   = (d == "easy"   || d == "0");
    var want_normal = (d == "normal" || d == "1");
    var want_hard   = (d == "hard"   || d == "2");

    // Get layer IDs
    var lidE = layer_get_id("TL_Visual_Easy");
    var lidN = layer_get_id("TL_Visual_Normal");
    var lidH = layer_get_id("TL_Visual_Hard");

    // Resolve tilemap IDs (these will be -1 if the layer has no tileset)
    var tmE = (lidE != -1) ? layer_tilemap_get_id(lidE) : -1;
    var tmN = (lidN != -1) ? layer_tilemap_get_id(lidN) : -1;
    var tmH = (lidH != -1) ? layer_tilemap_get_id(lidH) : -1;

    // Cache globals so stampers use the same IDs
    global.layer_vis_easy_id   = lidE;
    global.layer_vis_normal_id = lidN;
    global.layer_vis_hard_id   = lidH;

    global.tm_vis_easy   = tmE;
    global.tm_vis_normal = tmN;
    global.tm_vis_hard   = tmH;

    // Choose the ACTIVE visual tilemap:
    // - prefer requested difficulty if it exists
    // - otherwise fall back to the first valid tilemap (Hard, then Normal, then Easy)
    var use_tm  = -1;
    var showE = false, showN = false, showH = false;

    if (want_easy && tmE != -1)       { use_tm = tmE; showE = true; }
    else if (want_normal && tmN != -1){ use_tm = tmN; showN = true; }
    else if (want_hard && tmH != -1)  { use_tm = tmH; showH = true; }
    else
    {
        // FALLBACK TO ANYTHING THAT EXISTS (rm_level01 => Hard is the only valid one)
        if (tmH != -1)      { use_tm = tmH; showH = true; }
        else if (tmN != -1) { use_tm = tmN; showN = true; }
        else if (tmE != -1) { use_tm = tmE; showE = true; }
        else                { use_tm = -1; } // nothing exists
    }

    // Apply visibility (only show the layer we can actually draw)
    if (lidE != -1) layer_set_visible(lidE, showE);
    if (lidN != -1) layer_set_visible(lidN, showN);
    if (lidH != -1) layer_set_visible(lidH, showH);

    // Legacy compatibility (some older stamp/clear scripts use tm_visual)
    global.tm_visual = use_tm;
}