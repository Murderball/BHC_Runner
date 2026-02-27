/// obj_menu_controller : Draw GUI

if (!variable_instance_exists(id, "cam") || cam == noone) cam = view_camera[0];

var cx = variable_instance_exists(id, "menu_cam_x") ? menu_cam_x : camera_get_view_x(cam);
var cy = 0;

var spr_menu_background = asset_get_index("menu_background");
if (spr_menu_background >= 0) draw_sprite(spr_menu_background, 0, -cx, -cy);

function draw_btn_glow(_spr, _x, _y, _glow)
{
    if (_spr < 0) return;
    if (_glow > 0.01)
    {
        gpu_set_blendmode(bm_add);
        draw_set_color(c_white);
        draw_set_alpha(0.25 * _glow);
        draw_sprite(_spr, 0, _x - 2, _y);
        draw_sprite(_spr, 0, _x + 2, _y);
        draw_sprite(_spr, 0, _x, _y - 2);
        draw_sprite(_spr, 0, _x, _y + 2);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
    }
    draw_sprite(_spr, 0, _x, _y);
}

if (menu_state == MENU_STATE_PAGE2)
{
    draw_set_color(c_white);
    draw_text(980 - cx, 80, "LEVELS");
    draw_text(1160 - cx, 80, "BOSSES");

    if (spr_menu_level_select >= 0) draw_sprite(spr_menu_level_select, 0, 900 - cx, 120);

    for (var i = 0; i < array_length(level_btn); i++)
    {
        var b = level_btn[i];
        draw_set_alpha(b.enabled ? 1 : 0.45);
        draw_btn_glow(b.spr, b.x - cx, b.y, glow_level[i]);
        draw_set_alpha(1);
    }

    if (spr_menu_pointer >= 0 && sel_level >= 0 && sel_level < array_length(level_btn))
    {
        var _lp = level_btn[sel_level];
        draw_sprite(spr_menu_pointer, 0, (_lp.x - 34) - cx, _lp.y);
    }

    if (level_picked)
    {
        draw_btn_glow(btn_upgrade.spr, btn_upgrade.x - cx, btn_upgrade.y, glow_upgrade);
        draw_btn_glow(menu_LFG, btn_play.x - cx, btn_play.y, glow_play);
    }
}

// Dashed keyboard focus outline remains centralized in controller
if (array_length(btns) > 0 && sel_index >= 0 && sel_index < array_length(btns))
{
    var b_id = btns[sel_index];
    if (instance_exists(b_id))
    {
        var bx = b_id.x - cx;
        var by = b_id.y;
        var bw = b_id.w;
        var bh = b_id.h;

        draw_set_color(c_white);
        draw_set_alpha(1);
        draw_rectangle(bx - 4, by - 4, bx + bw + 4, by + bh + 4, true);
    }
}

if (debug_menu_overlay)
{
    draw_set_color(c_white);
    draw_text(24, 24, "menu_state: " + string(menu_state));
    draw_text(24, 46, "page_x: " + string(round(menu_page_x)));
}
