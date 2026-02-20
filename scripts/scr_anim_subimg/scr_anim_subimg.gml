/// scr_anim_subimg(spr, seed)
/// Returns an animated subimage index for `spr` based on real time (current_time),
/// so it keeps animating even if gameplay is "paused".
function scr_anim_subimg(_spr, _seed)
{
    if (_spr == -1) return 0;

    var frame_count = sprite_get_number(_spr);
    if (frame_count <= 1) return 0;

    // Use the sprite's own speed settings
    var spd  = sprite_get_speed(_spr);
    var styp = sprite_get_speed_type(_spr);

    // Convert to frames-per-second WITHOUT using the builtin name `fps`
    var anim_fps = spd;
    if (styp != spritespeed_framespersecond) {
        // frames-per-game-frame -> fps
        anim_fps = spd * game_get_speed(gamespeed_fps);
    }

    // Fallback if speed is 0
    if (anim_fps <= 0) anim_fps = 12;

    // current_time is milliseconds since game start (keeps ticking during pause overlay)
    var ticks = (current_time * 0.001) * anim_fps;

    var sub = (floor(ticks) + _seed) mod frame_count;
    if (sub < 0) sub += frame_count;

    return sub;
}
