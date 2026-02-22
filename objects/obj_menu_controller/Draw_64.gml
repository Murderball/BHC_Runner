/// obj_menu_controller : Draw GUI (white hover glow, fade in/out)

if (!variable_instance_exists(id, "cam") || cam == noone) cam = view_camera[0];

var cx = camera_get_view_x(cam);
var cy = camera_get_view_y(cam);

// Glow tuning
var g_off = 2;
var g_a   = 0.25;

// Helper: draw sprite with glow
function draw_btn_glow(_spr, _x, _y, _glow, _ga, _goff)
{
    if (_spr < 0) return;

    if (_glow > 0.01)
    {
        gpu_set_blendmode(bm_add);
        draw_set_color(c_white);
        draw_set_alpha(_ga * _glow);

        draw_sprite(_spr, 0, _x - _goff, _y);
        draw_sprite(_spr, 0, _x + _goff, _y);
        draw_sprite(_spr, 0, _x, _y - _goff);
        draw_sprite(_spr, 0, _x, _y + _goff);

        draw_sprite(_spr, 0, _x - _goff, _y - _goff);
        draw_sprite(_spr, 0, _x + _goff, _y - _goff);
        draw_sprite(_spr, 0, _x - _goff, _y + _goff);
        draw_sprite(_spr, 0, _x + _goff, _y + _goff);

        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
    }

    draw_sprite(_spr, 0, _x, _y);
}



// ------------------------------------------------------
// LEFT MENU PAGE
// ------------------------------------------------------
if (menu_state == 0)
{
    draw_btn_glow(btn_start.spr, btn_start.x - cx, btn_start.y - cy, glow_start, g_a, g_off);

    if (start_open)
    {
        draw_btn_glow(btn_story.spr, btn_story.x - cx, btn_story.y - cy, glow_story, g_a, g_off);
        draw_btn_glow(btn_arcade.spr, btn_arcade.x - cx, btn_arcade.y - cy, glow_arcade, g_a, g_off);

        if (arcade_diff_open)
        {
            draw_btn_glow(btn_easyL.spr,   btn_easyL.x - cx,   btn_easyL.y - cy,   glow_easyL, g_a, g_off);
            draw_btn_glow(btn_normalL.spr, btn_normalL.x - cx, btn_normalL.y - cy, glow_normalL, g_a, g_off);
            draw_btn_glow(btn_hardL.spr,   btn_hardL.x - cx,   btn_hardL.y - cy,   glow_hardL, g_a, g_off);
        }
    }

    draw_btn_glow(btn_options.spr, btn_options.x - cx, btn_options.y - cy, glow_options, g_a, g_off);

    var options_panel_visible = options_open || (start_open ? (sel_main == 3) : (sel_main == 1));
    if (options_panel_visible)
    {
        var px = btn_options.x + btn_options.w + 20;
        var py = btn_options.y - 12;
        var pw = options_panel_w;
        var ph = options_panel_h;

        var slider_min_x = px + options_panel_pad;
        var slider_max_x = px + pw - options_panel_pad - 80;
        var slider_y = py + 102;
        var knob_x = lerp(slider_min_x, slider_max_x, clamp(global.AUDIO_MASTER, 0, 1));
        var panel_hi = make_color_rgb(138, 214, 255);

        draw_set_alpha(0.28);
        draw_set_color(c_black);
        draw_roundrect(px - cx + 8, py - cy + 8, px - cx + pw + 8, py - cy + ph + 8, 10);

        draw_set_alpha(0.85);
        draw_set_color(make_color_rgb(16, 16, 20));
        draw_roundrect(px - cx, py - cy, px - cx + pw, py - cy + ph, 10);

        draw_set_alpha(1);
        draw_set_color(make_color_rgb(90, 90, 110));
        draw_roundrect(px - cx, py - cy, px - cx + pw, py - cy + ph, 10);

        draw_set_color(c_white);
        draw_text(px - cx + options_panel_pad, py - cy + 16, "GAME");
        draw_text(px - cx + options_panel_pad, py - cy + 52, "Master Volume");

        draw_set_halign(fa_right);
        draw_text(px - cx + pw - options_panel_pad, py - cy + 52, string(floor(global.AUDIO_MASTER * 100)) + "%");
        draw_set_halign(fa_left);

        draw_set_color(make_color_rgb(75, 75, 90));
        draw_line_width(slider_min_x - cx, slider_y - cy, slider_max_x - cx, slider_y - cy, 2);

        draw_set_color(panel_hi);
        draw_line_width(slider_min_x - cx, slider_y - cy, knob_x - cx, slider_y - cy, 3);

        draw_set_color(make_color_rgb(110, 110, 130));
        draw_line_width(lerp(slider_min_x, slider_max_x, 0.0) - cx, slider_y - cy - 5, lerp(slider_min_x, slider_max_x, 0.0) - cx, slider_y - cy + 5, 1);
        draw_line_width(lerp(slider_min_x, slider_max_x, 0.5) - cx, slider_y - cy - 5, lerp(slider_min_x, slider_max_x, 0.5) - cx, slider_y - cy + 5, 1);
        draw_line_width(lerp(slider_min_x, slider_max_x, 1.0) - cx, slider_y - cy - 5, lerp(slider_min_x, slider_max_x, 1.0) - cx, slider_y - cy + 5, 1);

        draw_set_color(c_white);
        draw_circle(knob_x - cx, slider_y - cy, 8, false);
        draw_set_color(panel_hi);
        draw_circle(knob_x - cx, slider_y - cy, 5, true);
        draw_set_color(c_white);
    }

    if (options_open)
    {
        draw_btn_glow(btn_game.spr, btn_game.x - cx, btn_game.y - cy, glow_game, g_a, g_off);
        draw_set_color(c_white);
        draw_text((btn_game.x + BTN_W + 20) - cx, (btn_game.y + 30) - cy, string(floor(global.AUDIO_MASTER * 100)) + "%");
        draw_btn_glow(btn_exit.spr, btn_exit.x - cx, btn_exit.y - cy, glow_exit, g_a, g_off);
    }
}

// ------------------------------------------------------
// RIGHT PAGE: Level Select (left) + Character Select (right)
// ------------------------------------------------------
if (menu_state == 2)
{
    // Headings (optional but helpful)
    draw_set_alpha(1);
    draw_set_color(c_white);
	draw_text((980 - cx),  (80 - cy), "LEVELS");
	draw_text((1160 - cx), (80 - cy), "BOSSES");


    // Level buttons (left of characters)
	for (var i = 0; i < array_length(level_btn); i++)
	{
	    var b = level_btn[i];
	    var sx = b.x - cx;
	    var sy = b.y - cy;

	    // Locked entries should look dimmer
	    var a = b.enabled ? 1 : 0.45;
	    draw_set_alpha(a);

	    // Always draw sprite now (locked uses menu_locked)
	    draw_btn_glow(b.spr, sx, sy, glow_level[i], g_a, g_off);

	    draw_set_alpha(1);
	}


    // Characters (dim + disabled until level picked)
    var char_alpha = level_picked ? 1 : 0.25;

    draw_set_alpha(char_alpha);

    for (var c = 0; c < array_length(char_btn); c++)
    {
        var cb = char_btn[c];
        var sx2 = cb.x - cx;
        var sy2 = cb.y - cy;

        var g = 0;
        if (level_picked)
        {
            if (c == 0) g = glow_char0;
            else if (c == 1) g = glow_char1;
            else if (c == 2) g = glow_char2;
            else if (c == 3) g = glow_char3;
        }

        // If not level_picked, we draw without glow (g=0)
        draw_btn_glow(cb.spr, sx2, sy2, g, g_a, g_off);
    }

    draw_set_alpha(1);

    if (!level_picked)
    {
        draw_set_color(c_white);
        draw_text((1500 - cx), (30 - cy), "Select a level to unlock character select");
    }

    // After pick: show Upgrade + Lets Fxckin Go (ONLY if level picked + char picked)
    if (level_picked && char_picked)
    {
        var ux = btn_upgrade.x - cx;
        var uy = btn_upgrade.y - cy;
        draw_btn_glow(btn_upgrade.spr, ux, uy, glow_upgrade, g_a, g_off);

        var px = btn_play.x - cx;
        var py = btn_play.y - cy;

        // match sprite size
        btn_play.w = sprite_get_width(menu_LFG);
        btn_play.h = sprite_get_height(menu_LFG);

        draw_btn_glow(menu_LFG, px, py, glow_play, g_a, g_off);
    }

    // BACK button
    draw_btn_glow(btn_back.spr, btn_back.x - cx, btn_back.y - cy, glow_back, g_a, g_off);
}
