/// scr_note_sprite_index(act)
/// Returns the sprite to use for a note action.
///
/// Note actions used in lanes:
///   atk1 / atk2 / atk3 / ult
///
/// IMPORTANT: spr_note_jump and spr_note_duck are no longer referenced.

function scr_note_sprite_index(act)
{
    if (is_undefined(act)) return spr_note;

    switch (act)
    {
        case "atk1": return spr_note_atk1;
        case "atk2": return spr_note_atk2;
        case "atk3": return spr_note_atk3;

        case "ult":
        case "ultimate":
            return spr_note_ultimate;

        default:
            // Safe fallback (never reference removed jump/duck sprites)
            return spr_note_atk1;
    }
}
