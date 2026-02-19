/// obj_room_non_gameplay : Step
// Quick test: press ESC to go back to main menu room if it exists.
if (keyboard_check_pressed(vk_escape))
{
    if (asset_get_index("rm_menu") != -1) room_goto(rm_menu);
}
