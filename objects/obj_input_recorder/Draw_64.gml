/// obj_input_recorder : Draw GUI

if (!variable_global_exists("editor_on") || !global.editor_on) exit;

var xg = ui_x;
var yg = ui_y;
var icon_gap = 88;

var held_jump = keyboard_check(vk_space);
var held_duck = keyboard_check(vk_shift);
var held_ult  = keyboard_check(ord("4"));

var icon_data = [
    { spr: spr_note_jump, held: held_jump },
    { spr: spr_note_duck, held: held_duck },
    { spr: spr_note_ultimate,  held: held_ult }
];

for (var i = 0; i < array_length(icon_data); i++)
{
    var d = icon_data[i];
    var alpha = d.held ? 1.0 : 0.35;
    var scl   = d.held ? 1.05 : 1.0;

    draw_set_alpha(alpha);
    draw_set_color(c_white);
    draw_sprite_ext(d.spr, 0, xg + i * icon_gap, yg, scl, scl, 0, c_white, alpha);
}

draw_set_alpha(1);
draw_set_color(c_white);
