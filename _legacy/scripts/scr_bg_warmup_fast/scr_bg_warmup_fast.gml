/// scr_bg_warmup_fast()
/// Touches BG sprites so they get pulled into texture pages ASAP.

function scr_bg_warmup_fast()
{
    for (var i = 0; i <= 43; i++)
    {
        var idx2 = (i < 10) ? ("0" + string(i)) : string(i);

        // just touching asset indices helps; if you also use texturegroup_load, this is extra safe
        asset_get_index("spr_bg_easy_" + idx2);
        asset_get_index("spr_bg_normal_" + idx2);
        asset_get_index("spr_bg_hard_" + idx2);
    }
}