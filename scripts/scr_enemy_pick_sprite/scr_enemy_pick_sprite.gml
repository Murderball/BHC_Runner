/// scr_enemy_pick_sprite(kind)
function scr_enemy_pick_sprite(kind)
{
    var spr = scr_enemy_sprite_from_kind(kind);
    if (spr != -1) return spr;

    // final fallback
    var s0 = asset_get_index("spr_poptart");
    if (s0 != -1) return s0;

    return -1;
}
