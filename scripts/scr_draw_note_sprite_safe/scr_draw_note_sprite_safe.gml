/// scr_draw_note_sprite_safe(spr, subimg, x, y)
/// Draws a visible fallback if sprite is invalid.

function scr_draw_note_sprite_safe(_spr, _sub, _x, _y)
{
    if (is_undefined(_spr) || _spr == -1) {
        // Fallback: bright box so you can always see notes
        draw_set_alpha(1);
        draw_set_color(c_aqua);
        draw_rectangle(_x - 10, _y - 10, _x + 10, _y + 10, false);
        draw_set_color(c_black);
        return;
    }
    draw_sprite(_spr, _sub, _x, _y);
}