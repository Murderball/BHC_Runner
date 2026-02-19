/// obj_upgrade_controller : Draw GUI

// Draw back button with glow
var g_off = 2;
var g_a   = 0.25;

var bx = btn_back_esc.x;
var by = btn_back_esc.y;

if (glow_back_esc > 0.01)
{
    gpu_set_blendmode(bm_add);
    draw_set_color(c_white);
    draw_set_alpha(g_a * glow_back_esc);

    draw_sprite(btn_back_esc.spr, 0, bx - g_off, by);
    draw_sprite(btn_back_esc.spr, 0, bx + g_off, by);
    draw_sprite(btn_back_esc.spr, 0, bx, by - g_off);
    draw_sprite(btn_back_esc.spr, 0, bx, by + g_off);

    draw_sprite(btn_back_esc.spr, 0, bx - g_off, by - g_off);
    draw_sprite(btn_back_esc.spr, 0, bx + g_off, by - g_off);
    draw_sprite(btn_back_esc.spr, 0, bx - g_off, by + g_off);
    draw_sprite(btn_back_esc.spr, 0, bx + g_off, by + g_off);

    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

draw_sprite(btn_back_esc.spr, 0, bx, by);
