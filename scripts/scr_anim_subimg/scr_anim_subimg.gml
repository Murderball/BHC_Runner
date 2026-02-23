///// scr_anim_subimg(_spr, _seed)
///// Returns a time-based subimage index that keeps animating while gameplay is paused.
//function scr_anim_subimg(_spr, _seed)
//{
//    if (!is_real(_spr) || _spr < 0) return 0;
//    if (asset_get_type(_spr) != asset_sprite) return 0;

//    var frame_count = sprite_get_number(_spr);
//    if (frame_count <= 1) return 0;

//    var speed_value = sprite_get_speed(_spr);
//    var speed_type = sprite_get_speed_type(_spr);

//    var anim_fps;
//    if (speed_type == spritespeed_framespersecond) {
//        anim_fps = speed_value;
//    } else if (speed_type == spritespeed_framespergameframe) {
//        anim_fps = speed_value * room_speed;
//    } else {
//        anim_fps = speed_value * room_speed;
//    }

//    if (!is_real(anim_fps) || anim_fps <= 0) anim_fps = 12;

//    var seed_real = real(_seed);
//    var seed_hash = sin(seed_real * 12.9898) * 43758.5453;
//    var seed_frac = seed_hash - floor(seed_hash);
//    if (seed_frac < 0) seed_frac += 1;
//    var seed_ms = seed_frac * 1000.0;

//    var t_sec = (current_time + seed_ms) / 1000.0;
//    var idx = floor(t_sec * anim_fps) mod frame_count;

//    if (idx < 0) idx += frame_count;
//    return clamp(idx, 0, frame_count - 1);
//}
