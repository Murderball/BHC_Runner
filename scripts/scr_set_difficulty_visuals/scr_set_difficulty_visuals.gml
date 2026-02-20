/// scr_set_difficulty_visuals(diff)
/// Shows the requested visual layer when available and updates global.tm_visual
/// to the visible, valid tilemap id.

function scr_set_difficulty_visuals(diff)
{
    var d = string_lower(string_replace_all(string(diff), " ", ""));

    var want_easy   = (d == "easy"   || d == "0");
    var want_normal = (d == "normal" || d == "1");
    var want_hard   = (d == "hard"   || d == "2");

    // If caller passed something unexpected, default intent to normal.
    if (!want_easy && !want_normal && !want_hard) want_normal = true;

    var lidE = layer_get_id("TL_Visual_Easy");
    var lidN = layer_get_id("TL_Visual_Normal");
    var lidH = layer_get_id("TL_Visual_Hard");

    var tmE = (lidE != -1) ? layer_tilemap_get_id(lidE) : -1;
    var tmN = (lidN != -1) ? layer_tilemap_get_id(lidN) : -1;
    var tmH = (lidH != -1) ? layer_tilemap_get_id(lidH) : -1;

    var selected_tm = -1;
    var show_easy = false;
    var show_normal = false;
    var show_hard = false;

    if (want_hard && tmH != -1) {
        selected_tm = tmH;
        show_hard = true;
    } else if (want_normal && tmN != -1) {
        selected_tm = tmN;
        show_normal = true;
    } else if (want_easy && tmE != -1) {
        selected_tm = tmE;
        show_easy = true;
    } else if (tmH != -1) {
        selected_tm = tmH;
        show_hard = true;
    } else if (tmN != -1) {
        selected_tm = tmN;
        show_normal = true;
    } else if (tmE != -1) {
        selected_tm = tmE;
        show_easy = true;
    }

    if (lidE != -1) layer_set_visible(lidE, show_easy);
    if (lidN != -1) layer_set_visible(lidN, show_normal);
    if (lidH != -1) layer_set_visible(lidH, show_hard);

    global.tm_visual = selected_tm;
}
