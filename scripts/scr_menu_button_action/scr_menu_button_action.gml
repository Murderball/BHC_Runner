/// @function scr_menu_button_action(role)
/// @param role
var role = argument0;

switch (role)
{
    case "start":
        start_open = !start_open;
    break;

    case "story":
        global.game_mode = "story";
        cam_target_x = page_right_x;
        menu_cam_target_x = page_right_x;
        menu_state = MENU_STATE_SCROLLING;
    break;

    case "arcade":
        global.game_mode = "arcade";
        cam_target_x = page_right_x;
        menu_cam_target_x = page_right_x;
        menu_state = MENU_STATE_SCROLLING;
    break;

    case "options":
        options_open = true;
    break;

    case "exit":
        game_end();
    break;

    case "back":
        cam_target_x = page_left_x;
        menu_cam_target_x = page_left_x;
        menu_state = MENU_STATE_SCROLLING;
    break;

    case "char_vocalist":
        global.char_id = 0;
        if (script_exists(asset_get_index("scr_start_game"))) script_execute(asset_get_index("scr_start_game"));
    break;

    case "char_guitarist":
        global.char_id = 1;
        if (script_exists(asset_get_index("scr_start_game"))) script_execute(asset_get_index("scr_start_game"));
    break;

    case "char_bassist":
        global.char_id = 2;
        if (script_exists(asset_get_index("scr_start_game"))) script_execute(asset_get_index("scr_start_game"));
    break;

    case "char_drummer":
        global.char_id = 3;
        if (script_exists(asset_get_index("scr_start_game"))) script_execute(asset_get_index("scr_start_game"));
    break;
}
