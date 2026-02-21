/// scr_note_sprite_index(act)
/// Returns the sprite to use for a note action.
function scr_note_sprite_index(act)
{
    if (is_undefined(act)) return spr_note;

    var act_norm = string_lower(string(act));

// Hard safety: ATK2 must resolve to spr_note_attk2, never ATK3.
var is_atk2 = (act_norm == "atk2" || act_norm == "attk2" || act_norm == "attack2");
if (!is_atk2 && variable_global_exists("ACT_ATK2")) {
    is_atk2 = (act_norm == string_lower(string(global.ACT_ATK2)));
}
if (is_atk2) {
    var spr_atk2 = asset_get_index("spr_note_attk2");
    if (spr_atk2 == -1) spr_atk2 = spr_note_attk2;
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

function scr_note_draw_color(act)
{
    var a = string_lower(string(act));
    switch (a)
    {
        case "atk2":
        case "attk2":
        case "attack2":
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
