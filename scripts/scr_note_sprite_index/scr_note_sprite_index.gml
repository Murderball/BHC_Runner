/// scr_note_sprite_index(act)
/// Returns the sprite to use for a note action.
function scr_note_sprite_index(act)
{
    if (is_undefined(act)) return spr_note;

    var act_norm = string_lower(string(act));

    // Hard safety: ATK2 must resolve to spr_note_attk2, never ATK3.
    if (act_norm == "atk2") {
        var spr_atk2 = spr_note_attk2;

        // If resource ids drift, prefer a name lookup of the canonical sprite.
        if (spr_atk2 == spr_note_attk3 || sprite_get_name(spr_atk2) == "spr_note_attk3") {
            var s_fix = asset_get_index("spr_note_attk2");
            if (s_fix != -1) spr_atk2 = s_fix;
        }

        return spr_atk2;
    }

    switch (act_norm)
    {
        case "jump": return spr_note_jump;
        case "duck": return spr_note_duck;
        case "atk1": return spr_note_attk1;
        case "atk3": return spr_note_attk3;

        case "ult":
        case "ultimate":
            return spr_note_ultimate;

        default:
            return spr_note_attk1;
    }
}

/// scr_note_draw_color(act)
/// Per-action note tint. Keep atk1 at the default color.
function scr_note_draw_color(act)
{
    switch (act)
    {
        case "atk2":
            return make_color_rgb(0, 200, 255);

        case "atk3":
            return make_color_rgb(190, 95, 255);

        case "ult":
        case "ultimate":
            return make_color_rgb(255, 170, 40);

        case "atk1":
        default:
            return c_white;
    }
}
