/// scr_bg_sprite_for_slot_diff(slot, diff, is_far)

function scr_bg_sprite_for_slot_diff(_slot, _diff, _is_far)
{
    var BG_COUNT = 44; // 00..43

    var diff = string_lower(string(_diff));
    if (diff != "easy" && diff != "normal" && diff != "hard") diff = "easy";

    var bgi = _slot mod BG_COUNT; // 0..43
    var idx2 = (bgi < 10) ? ("0" + string(bgi)) : string(bgi);

    var spr_name = _is_far
        ? ("spr_bg_far_" + diff + "_" + idx2)
        : ("spr_bg_"     + diff + "_" + idx2);

    var spr = asset_get_index(spr_name);

    if (spr == -1 && _is_far)
        spr = asset_get_index("spr_bg_" + diff + "_" + idx2);

    if (spr == -1)
        spr = asset_get_index("spr_bg_" + diff + "_00");

    if (spr == -1)
        spr = spr_bg_easy_00;

    return spr;
}