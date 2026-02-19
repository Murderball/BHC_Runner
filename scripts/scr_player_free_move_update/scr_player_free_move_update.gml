function scr_player_free_move_update(_spd)
{
    if (argument_count < 1) _spd = 8;

    // Only allow this in NON-gameplay rooms.
    if (script_exists(scr_player_is_gameplay_room) && scr_player_is_gameplay_room()) {
        return false;
    }

    // Optional: if you ever pause non-gameplay rooms, respect it.
    if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED) return true;
    if (variable_global_exists("STORY_PAUSED") && global.STORY_PAUSED) return true;

    // A/D + Arrow keys
    var left  = keyboard_check(vk_left)  || keyboard_check(ord("A"));
    var right = keyboard_check(vk_right) || keyboard_check(ord("D"));

    var mv = (right ? 1 : 0) - (left ? 1 : 0);

    // Move
    x += mv * _spd;

    // Keep inside the room (simple clamp)
    x = clamp(x, 0, room_width);

    // Basic animation handling (only if your sprites exist on the instance)
    if (mv != 0)
    {
        if (variable_instance_exists(id, "SPR_RUN")) sprite_index = SPR_RUN;
        image_speed = 1;

        // Face direction (optional; remove if you never want flips)
        image_xscale = (mv < 0) ? -1 : 1;
    }
    else
    {
        if (variable_instance_exists(id, "SPR_IDLE")) sprite_index = SPR_IDLE;
        image_speed = 0;
        image_index = 0;
    }

    // We handled this frame, caller should exit Step.
    return true;
}
