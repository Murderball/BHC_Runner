/// obj_upgrade_controller : Create

global.in_upgrade = true;

// --------------------------------------------------
// START UPGRADE MUSIC (looping)
// --------------------------------------------------
if (!variable_global_exists("upgrade_music_handle"))
{
    global.upgrade_music_handle = -1;
}

if (global.upgrade_music_handle < 0)
{
    scr_audio_route_apply();
    global.upgrade_music_handle = -1;
}

// Top-left back button (sprite: menu_back_esc)
btn_back_esc = {
    spr: menu_back_esc,
    x: 24,
    y: 24,
    w: sprite_get_width(menu_back_esc),
    h: sprite_get_height(menu_back_esc)
};

glow_back_esc = 0;
// Decide which character should show in upgrade
var cid = 0;
if (variable_global_exists("upgrade_char_id")) cid = global.upgrade_char_id;
else if (variable_global_exists("char_id"))    cid = global.char_id;
cid = clamp(cid, 0, 3);

global.upgrade_char_id = cid;
global.char_id = cid;

// Kill duplicates
if (object_exists(obj_char_preview))   with (obj_char_preview)   instance_destroy();
if (object_exists(obj_upgrade_player)) with (obj_upgrade_player) instance_destroy();

if (object_exists(obj_player_vocals)) with (obj_player_vocals) instance_destroy();
if (object_exists(obj_player_guitar)) with (obj_player_guitar) instance_destroy();
if (object_exists(obj_player_bass))   with (obj_player_bass)   instance_destroy();
if (object_exists(obj_player_drums))  with (obj_player_drums)  instance_destroy();

if (object_exists(obj_player_spawner)) with (obj_player_spawner) instance_destroy();

// Spawn upgrade player
var px = room_width * 0.5;
var py;

switch (cid)
{
    case 0: py = room_height - 80 ; break; // vocalist
    case 1: py = room_height - 80; break; // guitarist
    case 2: py = room_height - 80; break; // bassist
    case 3: py = room_height - 80; break; // drummer
    default: py = room_height ; break;
}

var p = instance_create_layer(px, py, "Instances", obj_upgrade_player);
p.depth = -100000;
p.image_xscale = 1;

if (variable_instance_exists(p, "ground_y")) p.ground_y = py;
