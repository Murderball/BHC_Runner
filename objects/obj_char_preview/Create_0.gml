/// obj_char_preview : Create

// Read upgrade target BEFORE choosing sprite
var cid = 0;
if (variable_global_exists("upgrade_char_id")) cid = global.upgrade_char_id;
else if (variable_global_exists("char_id"))    cid = global.char_id;

char_id = cid;

image_speed = 0.2;
image_index = 0;

// Pick correct idle sprite (adjust names to match your project)
switch (char_id)
{
    case 0: sprite_index = spr_vocalist_idle;  break;
    case 1: sprite_index = spr_guitarist_idle; break;
    case 2: sprite_index = spr_bassist_idle;   break;
    case 3: sprite_index = spr_drummer_idle;   break;
    default: sprite_index = spr_vocalist_idle; break;
}
