/// scr_set_difficulty_visuals(diff)
/// Shows only one visual layer; keeps collide always active.

function scr_set_difficulty_visuals(diff)
{
    var d = string_lower(string(diff));

    var show_easy   = (d == "easy"   || d == "0");
    var show_normal = (d == "normal" || d == "1");
    var show_hard   = (d == "hard"   || d == "2");

    // If caller passed something unexpected, default to normal
    if (!show_easy && !show_normal && !show_hard) show_normal = true;

    var lidE = layer_get_id("TL_Visual_Easy");
    var lidN = layer_get_id("TL_Visual_Normal");
    var lidH = layer_get_id("TL_Visual_Hard");

    if (lidE != -1) layer_set_visible(lidE, show_easy);
    if (lidN != -1) layer_set_visible(lidN, show_normal);
    if (lidH != -1) layer_set_visible(lidH, show_hard);

	
}