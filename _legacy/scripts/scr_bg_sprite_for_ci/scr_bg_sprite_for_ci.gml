/// scr_bg_sprite_for_ci(ci)
function scr_bg_sprite_for_ci(_ci)
{
    if (!is_real(_ci)) _ci = 0;
    _ci = floor(_ci);

    // Determine difficulty
    var diff = "normal";
    if (variable_global_exists("difficulty"))
        diff = string_lower(string(global.difficulty));
    else if (variable_global_exists("DIFFICULTY"))
        diff = string_lower(string(global.DIFFICULTY));

    var prefix = "spr_bg_normal_";
    if (diff == "easy") prefix = "spr_bg_easy_";
    else if (diff == "hard") prefix = "spr_bg_hard_";

    // Loop index (00–10)
    var frame_count = 11;
    var idx = ((_ci mod frame_count) + frame_count) mod frame_count;

    // Build "00".."10" safely
    var idx_str = string(idx);
    if (idx < 10) idx_str = "0" + idx_str;

    var spr_name = prefix + idx_str;
    var spr = asset_get_index(spr_name);

    if (spr == -1) spr = asset_get_index("spr_bg_normal_00");
    return spr;
}
