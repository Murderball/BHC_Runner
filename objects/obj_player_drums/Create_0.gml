/// obj_player_drums : Create
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
SPR_IDLE = spr_drummer_idle;
SPR_RUN  = spr_drummer_run;
SPR_JUMP = spr_drummer_jump;
SPR_DUCK = spr_drummer_duck;

// ----------------------------------------------------
// Lock collision mask
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

// Attack color flash
atk_flash_t = 0;
atk_flash_color = c_black;

just_spawned = true;
sprite_index = SPR_IDLE;

// 6-action runtime state
char_id = CHAR.DRUM;
act_cd = array_create(ACT.COUNT, 0);
if (variable_instance_exists(id, "ultimate_meter")) ult_meter = clamp(ultimate_meter, 0, 100);
else ult_meter = variable_instance_exists(id, "ult_meter") ? clamp(ult_meter, 0, 100) : 0;
