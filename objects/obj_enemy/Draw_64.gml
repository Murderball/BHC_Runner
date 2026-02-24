/// obj_enemy : Draw GUI

// Safety: if manager hasn't configured us yet, don't crash.
if (!variable_instance_exists(id, "t_anchor")) exit;
if (!variable_instance_exists(id, "margin_px")) margin_px = 0;
if (!variable_instance_exists(id, "lane")) lane = 0;
if (!variable_instance_exists(id, "enemy_kind")) enemy_kind = 0;
if (!variable_instance_exists(id, "y_gui")) y_gui = -1;
if (!variable_instance_exists(id, "hp_max")) hp_max = 0;
if (!variable_instance_exists(id, "hp")) hp = 0;

var gw = display_get_gui_width();
var gh = display_get_gui_height();

var xg = scr_note_screen_x(t_anchor);

// Cull if far off
if (xg < -margin_px - 400) exit;
if (xg > gw + margin_px + 400) exit;

// Y placement
var yg;
if (is_real(y_gui) && y_gui >= 0) {
    yg = y_gui;
} else if (variable_global_exists("LANE_Y") && is_array(global.LANE_Y)) {
    var li = clamp(lane, 0, array_length(global.LANE_Y) - 1);
    yg = global.LANE_Y[li];
} else {
    yg = gh * 0.5;
}

// Sprite by kind
var spr = scr_enemy_sprite_from_kind(enemy_kind);
if (spr == -1) spr = asset_get_index("spr_poptart");

// draw
if (spr != -1) draw_sprite(spr, 0, xg, yg - 48);

// Health bar
if (hp_max > 0)
{
    var bar_w = 60;
    var bar_h = 8;
    var bx1 = xg - bar_w * 0.5;
    var by1 = yg - 110;
    var bx2 = bx1 + bar_w;
    var by2 = by1 + bar_h;

    var denom = hp_max;
if (denom == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom = 1;
}
var r = clamp(hp / denom, 0, 1);

    draw_set_alpha(0.85);
    draw_set_color(c_white);
    draw_rectangle(bx1 - 1, by1 - 1, bx2 + 1, by2 + 1, false);

    draw_set_color(c_lime);
    draw_rectangle(bx1, by1, bx1 + bar_w * r, by2, false);

    draw_set_alpha(1);
}