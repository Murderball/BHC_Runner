/// obj_lightning_strike : Create
if (!variable_instance_exists(id, "target_id")) target_id = noone;

life = room_speed * 0.20;
hit_done = false;

top_y_offset = 180;
jag = 10;
segs = 6;

dmg = 1;

// init cached positions
strike_x = x;
strike_y_top = y - top_y_offset;
strike_y_bot = y;

if (instance_exists(target_id)) {
    strike_x = target_id.x;
    strike_y_bot = target_id.y;
    strike_y_top = strike_y_bot - top_y_offset;
}
