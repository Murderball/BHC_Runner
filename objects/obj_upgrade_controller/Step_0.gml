/// obj_upgrade_controller : Step

// Helper: return to menu (RIGHT page, no auto Upgrade/LFG)
function do_back_to_menu()
{
    global.in_upgrade = false;
    global.in_menu = true;

    // Tell menu to start on right page (but don't auto-show Upgrade/LFG)
    global.menu_return_to_right = true;

    room_goto(rm_menu);
}

// ESC returns to menu
if (keyboard_check_pressed(vk_escape))
{
    do_back_to_menu();
    exit;
}

// Clickable back button (top-left)
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var hit_back =
    (mx >= btn_back_esc.x && mx <= btn_back_esc.x + btn_back_esc.w &&
     my >= btn_back_esc.y && my <= btn_back_esc.y + btn_back_esc.h);

if (mouse_check_button_pressed(mb_left) && hit_back)
{
    do_back_to_menu();
    exit;
}

// Smooth glow
var target = hit_back ? 1 : 0;
glow_back_esc = lerp(glow_back_esc, target, 0.20);
