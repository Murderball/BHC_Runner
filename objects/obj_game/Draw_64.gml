/// obj_game : Draw GUI
// --------------------------------------------------
// MENU GUARD: never draw gameplay overlays in rm_menu
// --------------------------------------------------
if (room == rm_menu || (variable_global_exists("in_menu") && global.in_menu)) exit;

// --- Draw GUI stuff ONCE ---
scr_draw_gameplay_gui();

if (variable_global_exists("editor_on") && global.editor_on) {
    scr_editor_draw_gui();
}

// --- ALWAYS restore draw state so world sprites never inherit bad settings next frame ---
draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);
