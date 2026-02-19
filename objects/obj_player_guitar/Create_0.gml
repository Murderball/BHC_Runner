/// obj_player_guitar : Create
menu_preview = (room == rm_menu);

// ----------------------------------------------------
// Runner positioning
// ----------------------------------------------------
player_screen_x = 348;
depth = -50;

// ----------------------------------------------------
// Movement
// ----------------------------------------------------
hsp = 0;
vsp = 0;
grounded = false;

// ----------------------------------------------------
// Editor/play transition
// ----------------------------------------------------
prev_editor_on = false;
player_world_y = y;
spawn_y = y;

// ----------------------------------------------------
// Sprites
// ----------------------------------------------------
SPR_IDLE = spr_guitarist_idle;
SPR_RUN  = spr_guitarist_run;
SPR_JUMP = spr_guitarist_jump;
SPR_DUCK = spr_guitarist_duck; // slide/duck

// ----------------------------------------------------
// IMPORTANT: lock collision mask so duck sprite can't change it
// (prevents falling through ground on duck)
// ----------------------------------------------------
mask_index = SPR_IDLE;

// ----------------------------------------------------
// Animation/state
// ----------------------------------------------------
state = "run";
image_index = 0;
image_speed = 1;

duck_timer = 0;

anim_lock = 0;
anim_lock_state = "run";

set_state = function(_s)
{
    if (state == _s) return;
    state = _s;
    image_index = 0;
};

lock_anim = function(_s, _frames)
{
    anim_lock = max(anim_lock, _frames);
    anim_lock_state = _s;
    set_state(_s);
};

just_spawned = true;
sprite_index = SPR_IDLE;
