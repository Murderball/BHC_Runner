/// obj_upgrade_player : Create
/// Simple controllable character for rm_upgrade (no runner/chunk systems required)

depth = -100000; // ALWAYS in front of backgrounds/pillars unless something is even lower

// Which character to show
char_id = 0;
if (variable_global_exists("upgrade_char_id")) char_id = global.upgrade_char_id;
else if (variable_global_exists("char_id"))    char_id = global.char_id;

char_id = clamp(char_id, 0, 3);

// Basic motion
hsp = 0;
vsp = 0;
grav = 0.6;
walk_spd = 8;
jump_spd = -15;
ground_y = y; // "floor" for upgrade room

// Pick sprite sets (adjust names if yours differ)
switch (char_id)
{
    case 0:
        SPR_IDLE = spr_vocalist;
        SPR_RUN  = spr_vocalist_run;
        SPR_JUMP = spr_vocalist_jump;
        SPR_DUCK = spr_vocalist_duck;
    break;

    case 1:
        SPR_IDLE = spr_guitarist;
        SPR_RUN  = spr_guitarist_run;
        SPR_JUMP = spr_guitarist_jump;
        SPR_DUCK = spr_guitarist_duck;
    break;

    case 2:
        SPR_IDLE = spr_bassist;
        SPR_RUN  = spr_bassist_run;
        SPR_JUMP = spr_bassist_jump;
        SPR_DUCK = spr_bassist_duck;
    break;

    case 3:
        SPR_IDLE = spr_drummer;
        SPR_RUN  = spr_drummer_run;
        SPR_JUMP = spr_drummer_jump;
        SPR_DUCK = spr_drummer_duck;
    break;
}

sprite_index = SPR_IDLE;
image_speed = 1;
image_index = 0;
facing = 1;
