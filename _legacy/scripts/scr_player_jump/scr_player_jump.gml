function scr_player_jump()
{
    if (!instance_exists(obj_player)) return;

    with (obj_player)
    {
        if (grounded && !jump_buffered)
        {
            vsp = jump_force;
            grounded = false;
            jump_buffered = true;
        }
    }
}
