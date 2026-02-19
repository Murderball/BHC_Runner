/// obj_lightning_strike : Step
if (instance_exists(target_id)) {
    strike_x = target_id.x;
    strike_y_bot = target_id.y;
    strike_y_top = strike_y_bot - top_y_offset;
}

if (!hit_done) {
    hit_done = true;

    // Generic damage support: hp variable if it exists
    if (instance_exists(target_id) && variable_instance_exists(target_id, "hp")) {
        target_id.hp -= dmg;
    }
}
if (instance_exists(target_id) && variable_instance_exists(target_id, "hit_flash")) {
    target_id.hit_flash = 6; // frames
}

life--;
if (life <= 0) instance_destroy();
