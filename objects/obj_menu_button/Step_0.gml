/// obj_menu_button : Step
var ctrl = instance_find(obj_menu_controller, 0);
if (!instance_exists(ctrl)) exit;

if (!is_string(button_role)) button_role = "";
if (sprite_index != -1)
{
    w = sprite_width;
    h = sprite_height;
}

var cx = ctrl.menu_cam_x;
var mx_world = device_mouse_x_to_gui(0) + cx;
var my_world = device_mouse_y_to_gui(0);

var visible_on_page = (button_page == 0 && ctrl.menu_state == ctrl.MENU_STATE_INIT) || (button_page == 1 && ctrl.menu_state == ctrl.MENU_STATE_PAGE2);
hover = visible_on_page && point_in_rectangle(mx_world, my_world, x, y, x + w, y + h);

glow = lerp(glow, hover ? 1 : 0, 0.18);

var click = mouse_check_button_pressed(mb_left);
if (visible_on_page && button_role != "" && (click && hover))
{
    with (obj_menu_controller)
    {
        scr_menu_button_action(other.button_role);
    }
}

if (visible_on_page && instance_exists(ctrl) && array_length(ctrl.btns) > 0)
{
    if (ctrl.sel_index >= 0 && ctrl.sel_index < array_length(ctrl.btns) && ctrl.btns[ctrl.sel_index] == id)
    {
        var ok = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
        if (ok && button_role != "")
        {
            with (obj_menu_controller)
            {
                scr_menu_button_action(other.button_role);
            }
        }
    }
}
