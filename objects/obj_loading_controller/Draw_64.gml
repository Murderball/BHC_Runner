/// obj_loading_controller : Draw GUI

var gw = display_get_gui_width();
var gh = display_get_gui_height();

var spr = -1;
if (bg_i >= 0) spr = loading_bgs[bg_i];

// Zoom factor
var zt = 1;
if (zoom_ms > 0)
{
    var denom_zoom = zoom_ms;
    if (denom_zoom == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_zoom = 1;
    }
    zt = zoom_accum_ms / denom_zoom;
}
zt = clamp(zt, 0, 1);
var z = lerp(zoom_start, zoom_end, zt);

// Pan (very subtle drift)
var px = pan_x * zt;
var py = pan_y * zt;

// ----------------------------------
// Draw background (cover full screen)
// ----------------------------------
if (spr >= 0)
{
    var sw = sprite_get_width(spr);
    var sh = sprite_get_height(spr);

    var denom_sw = sw;
    if (denom_sw == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_sw = 1;
    }
    var sx = gw / denom_sw;
    var denom_sh = sh;
    if (denom_sh == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_sh = 1;
    }
    var sy = gh / denom_sh;
    var s  = max(sx, sy);

    // apply zoom
    s *= z;

    var dw = sw * s;
    var dh = sh * s;

    var dx = (gw - dw) * 0.5 + px;
    var dy = (gh - dh) * 0.5 + py;

    draw_sprite_ext(spr, 0, dx, dy, s, s, 0, c_white, 1);
}
else
{
    draw_set_color(c_black);
    draw_rectangle(0, 0, gw, gh, false);
}

// ----------------------------------
// Subtle dim overlay (always on)
// ----------------------------------
draw_set_alpha(0.12);
draw_set_color(c_black);
draw_rectangle(0, 0, gw, gh, false);
draw_set_alpha(1);

// ----------------------------------
// LOADING text
// ----------------------------------
draw_set_color(c_white);
draw_text(gw * 0.5 - 60, gh * 0.5 - 10, "LOADING...");

// ----------------------------------
// Fade-in from black (on top of everything)
// ----------------------------------
var ft = 1;
if (fade_in_ms > 0)
{
    var denom_fade = fade_in_ms;
    if (denom_fade == 0)
    {
        show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
        denom_fade = 1;
    }
    ft = fade_accum_ms / denom_fade;
}
ft = clamp(ft, 0, 1);

var black_a = 1 - ft;
if (black_a > 0)
{
    draw_set_alpha(black_a);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1);
}
