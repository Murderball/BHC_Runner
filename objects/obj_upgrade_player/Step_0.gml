/// obj_upgrade_player : Step
/// Minimal controls for upgrade room

// Inputs (keyboard)
var L = keyboard_check(vk_left)  || keyboard_check(ord("A"));
var R = keyboard_check(vk_right) || keyboard_check(ord("D"));
var J = keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var D = keyboard_check(vk_down)  || keyboard_check(ord("S"));

// Horizontal
hsp = 0;
if (L) { hsp = -walk_spd; facing = -1; }
if (R) { hsp =  walk_spd; facing =  1; }

x += hsp;

// Jump/Gravity
vsp += grav;

if (y >= ground_y)
{
    y = ground_y;
    vsp = 0;

    if (J && !D)
        vsp = jump_spd;
}

y += vsp;

// Simple animation state
if (y < ground_y - 1)
{
    sprite_index = SPR_JUMP;
}
else if (D)
{
    sprite_index = SPR_DUCK;
}
else if (abs(hsp) > 0.1)
{
    sprite_index = SPR_RUN;
}
else
{
    sprite_index = SPR_IDLE;
}

image_xscale = facing;
