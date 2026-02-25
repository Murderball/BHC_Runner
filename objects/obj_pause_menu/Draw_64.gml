/// obj_pause_menu : Draw GUI

if (!paused) exit;

var gw = display_get_gui_width();
var gh = display_get_gui_height();

// ----------------------------------------------------
// 1) Fake blur using application_surface down/upscale
//    (Correctly mapped into GUI space)
// ----------------------------------------------------
var app = application_surface;

if (surface_exists(app))
{
    var appw = surface_get_width(app);
    var apph = surface_get_height(app);

    // build small blur surface based on app surface size
    var bw = max(2, floor(appw * blur_scale));
    var bh = max(2, floor(apph * blur_scale));

    if (!surface_exists(blur_surf))
    {
        blur_surf = surface_create(bw, bh);
    }
    else if (surface_get_width(blur_surf) != bw || surface_get_height(blur_surf) != bh)
    {
        surface_free(blur_surf);
        blur_surf = surface_create(bw, bh);
    }

    // draw app -> blur_surf (downscaled)
    surface_set_target(blur_surf);
    draw_clear_alpha(c_black, 0);

    gpu_set_texfilter(true);

    // scale factors from app size to blur size
    var denom_appw = appw;
if (denom_appw == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_appw = 1;
}
var sx_down = bw / denom_appw;
    var denom_apph = apph;
if (denom_apph == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_apph = 1;
}
var sy_down = bh / denom_apph;

    draw_surface_ext(app, 0, 0, sx_down, sy_down, 0, c_white, 1);

    surface_reset_target();

    // draw blur_surf -> GUI full screen (upscaled)
    var denom_bw = bw;
if (denom_bw == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_bw = 1;
}
var sx_up = gw / denom_bw;
    var denom_bh = bh;
if (denom_bh == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_bh = 1;
}
var sy_up = gh / denom_bh;

    for (var p = 0; p < blur_passes; p++)
    {
        var j = blur_jitter * (p + 1);

        var denom_blur = blur_passes;
if (denom_blur == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom_blur = 1;
}
draw_set_alpha(blur_alpha * (1.0 / denom_blur));

        // main
        draw_surface_ext(blur_surf, 0, 0, sx_up, sy_up, 0, c_white, 1);

        // subtle smear/jitter
        draw_surface_ext(blur_surf,  j, 0, sx_up, sy_up, 0, c_white, 1);
        draw_surface_ext(blur_surf, -j, 0, sx_up, sy_up, 0, c_white, 1);
        draw_surface_ext(blur_surf, 0,  j, sx_up, sy_up, 0, c_white, 1);
        draw_surface_ext(blur_surf, 0, -j, sx_up, sy_up, 0, c_white, 1);
    }

    draw_set_alpha(1);
    gpu_set_texfilter(false);
}

// ----------------------------------------------------
// 2) Dim overlay (tune as needed)
// ----------------------------------------------------
draw_set_alpha(0.25);
draw_set_color(c_black);
draw_rectangle(0, 0, gw, gh, false);
draw_set_alpha(1);

if (menu_game_open)
{
    var panel_w2 = 640;
    var panel_h2 = 360;
    var panel_x2 = gw * 0.5 - panel_w2 * 0.5;
    var panel_y2 = gh * 0.5 - panel_h2 * 0.5;
    scr_menu_game_draw(id, panel_x2 + 60, panel_y2 + 120, panel_w2 - 120);
    exit;
}

// ------------------------------------------------------
// 3) Sprite buttons + hover glow
// ------------------------------------------------------
var glow_px    = 2;
var glow_alpha = 0.35;

for (var i = 0; i < array_length(items); i++)
{
    var r   = btn[i];
    var spr = spr_items[i];

    var cx = (r.x1 + r.x2) * 0.5;
    var cy = (r.y1 + r.y2) * 0.5;

    if (spr >= 0)
    {
        if (glow[i] > 0.01)
        {
            gpu_set_blendmode(bm_add);
            draw_set_color(c_white);
            draw_set_alpha(glow_alpha * glow[i]);

            draw_sprite_ext(spr, 0, cx - glow_px, cy, spr_scale, spr_scale, 0, c_white, glow_alpha * glow[i]);
            draw_sprite_ext(spr, 0, cx + glow_px, cy, spr_scale, spr_scale, 0, c_white, glow_alpha * glow[i]);
            draw_sprite_ext(spr, 0, cx, cy - glow_px, spr_scale, spr_scale, 0, c_white, glow_alpha * glow[i]);
            draw_sprite_ext(spr, 0, cx, cy + glow_px, spr_scale, spr_scale, 0, c_white, glow_alpha * glow[i]);

            draw_sprite_ext(spr, 0, cx - glow_px, cy - glow_px, spr_scale, spr_scale, 0, c_white, glow_alpha * glow[i]);
            draw_sprite_ext(spr, 0, cx + glow_px, cy - glow_px, spr_scale, spr_scale, 0, c_white, glow_alpha * glow[i]);
            draw_sprite_ext(spr, 0, cx - glow_px, cy + glow_px, spr_scale, spr_scale, 0, c_white, glow_alpha * glow[i]);
            draw_sprite_ext(spr, 0, cx + glow_px, cy + glow_px, spr_scale, spr_scale, 0, c_white, glow_alpha * glow[i]);

            draw_set_alpha(1);
            gpu_set_blendmode(bm_normal);
        }

        draw_sprite_ext(spr, 0, cx, cy, spr_scale, spr_scale, 0, c_white, 1);

    }
}



var pause_options_draw_active = (!menu_game_open) && ((sel == 2) || (hover_i == 2) || options_slider_drag);
if (pause_options_draw_active && array_length(btn) > 2)
{
    var _opr_draw = btn[2];
    scr_ui_master_volume_panel_draw(_opr_draw.x1, _opr_draw.y1, _opr_draw.x2 - _opr_draw.x1, _opr_draw.y2 - _opr_draw.y1, true);
}

// ------------------------------------------------------
// 4) Keyboard dashed selection outline
// ------------------------------------------------------
if (kb_nav_timer > 0)
{
    var rr = btn[sel];

    var x1 = rr.x1 - 6;
    var y1 = rr.y1 - 6;
    var x2 = rr.x2 + 6;
    var y2 = rr.y2 + 6;

    var seg  = 10;
    var gap  = 6;
    var step = seg + gap;
    var ph   = kb_dash_phase;

    draw_set_color(c_white);
    draw_set_alpha(1);

    for (var dx = x1 - ph; dx < x2; dx += step)
    {
        var xa = max(dx, x1);
        var xb = min(dx + seg, x2);
        if (xb > xa) draw_line(xa, y1, xb, y1);
    }
    for (var dx2 = x1 - ph; dx2 < x2; dx2 += step)
    {
        var xa2 = max(dx2, x1);
        var xb2 = min(dx2 + seg, x2);
        if (xb2 > xa2) draw_line(xa2, y2, xb2, y2);
    }
    for (var dy = y1 - ph; dy < y2; dy += step)
    {
        var ya = max(dy, y1);
        var yb = min(dy + seg, y2);
        if (yb > ya) draw_line(x1, ya, x1, yb);
    }
    for (var dy2 = y1 - ph; dy2 < y2; dy2 += step)
    {
        var ya2 = max(dy2, y1);
        var yb2 = min(dy2 + seg, y2);
        if (yb2 > ya2) draw_line(x2, ya2, x2, yb2);
    }
}


// Leaderboard panel drawing is owned ONLY by obj_menu_controller : Draw GUI
