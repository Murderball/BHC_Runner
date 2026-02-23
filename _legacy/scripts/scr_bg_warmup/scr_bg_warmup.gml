/// scr_bg_warmup()
/// Draws each BG sprite once (offscreen) to warm GPU pages.
/// Call once on boot AFTER texturegroup_load.

function scr_bg_warmup()
{
    for (var i = 0; i <= 43; i++)
    {
        var idx2 = (i < 10) ? ("0" + string(i)) : string(i);

        var s;

        s = asset_get_index("spr_bg_easy_" + idx2);   if (s != -1) draw_sprite(s, 0, -10000, -10000);
        s = asset_get_index("spr_bg_normal_" + idx2); if (s != -1) draw_sprite(s, 0, -10000, -10000);
        s = asset_get_index("spr_bg_hard_" + idx2);   if (s != -1) draw_sprite(s, 0, -10000, -10000);
    }
}