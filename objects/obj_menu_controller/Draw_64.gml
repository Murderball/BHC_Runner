/// obj_menu_controller : Draw GUI (white hover glow, fade in/out)

if (!variable_instance_exists(id, "cam") || cam == noone) cam = view_camera[0];

var cx = camera_get_view_x(cam);
var cy = camera_get_view_y(cam);

// Glow tuning
var g_off = 2;
var g_a   = 0.25;

// Helper: draw sprite with shadow + glow
function draw_btn_glow(_spr, _x, _y, _glow, _ga, _goff)
{
    if (_spr < 0) return;

    // -----------------------------------
    // 1) BLACK DROP SHADOW (new)
    // -----------------------------------
    draw_set_color(c_black);
    draw_set_alpha(0.65);

    var shadow_offset = 3;

    draw_sprite(_spr, 0, _x + shadow_offset, _y + shadow_offset);

    draw_set_alpha(1);

    // -----------------------------------
    // 2) WHITE GLOW (existing)
    // -----------------------------------
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

    // -----------------------------------
    // 3) MAIN SPRITE
    // -----------------------------------
    draw_set_color(c_white);
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
        scr_ui_master_volume_panel_draw(btn_options.x - cx, btn_options.y - cy, btn_options.w, btn_options.h, true);
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

// Only show leaderboard button on LEFT menu page
if (menu_state == 0 && sprite_exists(spr_leaderboard))
{
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    lb_btn_w = sprite_get_width(spr_leaderboard);
    lb_btn_h = sprite_get_height(spr_leaderboard);

    // Your anchored sun position
    lb_btn_x = (gui_w * 0.62) - (lb_btn_w * 0.5);
    lb_btn_y = (gui_h * 0.34) - (lb_btn_h * 0.5);

    var lb_mx = device_mouse_x_to_gui(0);
    var lb_my = device_mouse_y_to_gui(0);

    var lb_hover = point_in_rectangle(lb_mx, lb_my, lb_btn_x, lb_btn_y, lb_btn_x + lb_btn_w, lb_btn_y + lb_btn_h);
    var lb_alpha = lb_hover ? (0.85 + 0.15 * sin(current_time * 0.01)) : 1;

    draw_set_alpha(lb_alpha);
    draw_sprite(spr_leaderboard, 0, lb_btn_x, lb_btn_y);
    draw_set_alpha(1);

    // Dropdown only on left page
    if (lb_open && script_exists(scr_draw_leaderboard_panel))
    {
        var dd_x = lb_btn_x;
        var dd_y = lb_btn_y + lb_btn_h + 12;
        scr_draw_leaderboard_panel(dd_x, dd_y, 420, 420, "right",
            global.profile_view_level_key,
            global.profile_view_difficulty,
            true);
    }
}
