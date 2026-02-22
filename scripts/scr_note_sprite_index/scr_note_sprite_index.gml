/// scr_note_sprite_index(act)
/// Backward-compatible wrapper for the centralized note sprite resolver.
function scr_note_sprite_index(act)
{
    return scr_note_sprite(act);
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
