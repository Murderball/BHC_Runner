/// scr_note_sprite_index(act)
/// Returns the sprite to use for a note action.
function scr_note_sprite_index(act)
{
    if (is_undefined(act)) return spr_note;

    switch (act)
    {
        case "jump": return spr_note_jump;
        case "duck": return spr_note_duck;
        case "atk1": return spr_note_atk1;
        case "atk2": return spr_note_atk2;
        case "atk3": return spr_note_atk3;

        case "ult":
        case "ultimate":
            return spr_note_ultimate;

        default:
            return spr_note_atk1;
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
