/// obj_menu_button : Draw GUI
var ctrl = instance_find(obj_menu_controller, 0);
if (!instance_exists(ctrl)) exit;

var visible_on_page = (button_page == 0 && ctrl.menu_state == ctrl.MENU_STATE_INIT) || (button_page == 1 && ctrl.menu_state == ctrl.MENU_STATE_PAGE2);
if (!visible_on_page) exit;

var cx = ctrl.menu_cam_x;
var sx = x - cx;
var sy = y;

if (glow > 0.01)
{
    gpu_set_blendmode(bm_add);
    draw_set_color(c_white);
    draw_set_alpha(0.25 * glow);

    draw_sprite(sprite_index, image_index, sx - 2, sy);
    draw_sprite(sprite_index, image_index, sx + 2, sy);
    draw_sprite(sprite_index, image_index, sx, sy - 2);
    draw_sprite(sprite_index, image_index, sx, sy + 2);

    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

draw_sprite(sprite_index, image_index, sx, sy);
