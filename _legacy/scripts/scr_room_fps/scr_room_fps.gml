/// scr_room_fps()
/// Returns current room FPS (compat-safe).
/// NOTE: Uses room_speed (deprecated but required for this runtime).
function scr_room_fps()
{
    var v = room_speed;
    if (!is_real(v) || v <= 0) v = 60;
    return v;
}
