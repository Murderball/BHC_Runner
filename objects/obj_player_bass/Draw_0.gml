/// obj_player : Draw
draw_set_alpha(1);
var draw_col = c_black;
if (variable_instance_exists(id, "atk_flash_t") && variable_instance_exists(id, "atk_flash_color") && atk_flash_t > 0) {
    draw_col = atk_flash_color;
}
draw_set_color(draw_col);
gpu_set_blendmode(bm_normal);
draw_self();
draw_set_color(c_black);
