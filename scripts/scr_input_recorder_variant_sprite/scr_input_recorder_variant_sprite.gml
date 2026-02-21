/// scr_input_recorder_variant_sprite(variant_string)
/// Reuses gameplay note sprite mapping (scr_note_sprite_index) for known note variants.
function scr_input_recorder_variant_sprite(variant_string)
{
    var v = string_lower(string(variant_string));
    var act = "";

    switch (v)
    {
        case "attack1":
        case "atk1":
            act = "atk1";
            break;

        case "attack2":
        case "atk2":
            act = "atk2";
            break;

        case "attack3":
        case "atk3":
            act = "atk3";
            break;

        case "ultimate":
        case "ult":
            act = "ultimate";
            break;

        default:
            return { spr: -1, anim: -1, variant: variant_string };
    }

    if (!script_exists(scr_note_sprite_index)) {
        return { spr: -1, anim: -1, variant: variant_string };
    }

    var spr = scr_note_sprite_index(act);
    if (!is_real(spr) || spr < 0) {
        return { spr: -1, anim: -1, variant: variant_string };
    }

    return {
        spr: spr,
        anim: sprite_get_name(spr),
        variant: variant_string
    };
}
