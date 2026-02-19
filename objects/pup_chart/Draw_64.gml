/// pup_* : Draw GUI

var now_t = scr_chart_time();
var gw    = display_get_gui_width();

// Timeline-driven X (exactly like enemies)
var xg = scr_note_screen_x(t_anchor);

// Cull if far off-screen
if (xg < -margin_px - 400) exit;
if (xg > gw + margin_px + 400) exit;

// Lane-free Y (set by marker / manager)
var yg = (is_real(y_gui) && y_gui >= 0) ? y_gui : display_get_gui_height() * 0.5;

// Draw sprite
if (spr != -1) {
    draw_sprite(spr, 0, xg, yg);
} else {
    // Debug fallback box so you still see something if sprite isn't found
    draw_set_color(c_aqua);
    draw_rectangle(xg - 12, yg - 12, xg + 12, yg + 12, false);
    draw_set_color(c_white);
}
