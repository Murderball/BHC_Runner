/// obj_menu_controller : Step

if (!variable_instance_exists(id, "cam") || cam == noone) cam = view_camera[0];
if (!variable_instance_exists(id, "menu_cam_x")) menu_cam_x = camera_get_view_x(cam);
if (!variable_instance_exists(id, "menu_cam_target_x")) menu_cam_target_x = menu_cam_x;
if (!variable_instance_exists(id, "menu_cam_speed")) menu_cam_speed = 0.15;
if (!variable_instance_exists(id, "menu_cam_y")) menu_cam_y = 0;

var ok = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
var back = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace);
var up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
if (keyboard_check_pressed(vk_f3)) debug_menu_overlay = !debug_menu_overlay;

var held_dir = keyboard_check(vk_up) || keyboard_check(ord("W")) || keyboard_check(vk_down) || keyboard_check(ord("S")) || keyboard_check(vk_left) || keyboard_check(ord("A")) || keyboard_check(vk_right) || keyboard_check(ord("D"));
var used_kb = held_dir || ok || back;
if (used_kb) kb_nav_timer = 90;
if (kb_nav_timer > 0) kb_nav_timer--;
kb_dash_phase = (kb_dash_phase + 1) & 15;

menu_cam_target_x = clamp(menu_cam_target_x, MENU_PAGE_1_X, MENU_PAGE_2_X);
menu_cam_x = lerp(menu_cam_x, menu_cam_target_x, menu_cam_speed);
if (abs(menu_cam_x - menu_cam_target_x) < 0.5) menu_cam_x = menu_cam_target_x;
menu_cam_x = clamp(menu_cam_x, min_cam_x, max_cam_x);
menu_cam_y = clamp(menu_cam_y, min_cam_y, max_cam_y);
camera_set_view_pos(cam, menu_cam_x, menu_cam_y);

cam_x = menu_cam_x;
cam_target_x = menu_cam_target_x;
cam_y = menu_cam_y;
menu_page_x = menu_cam_x;
menu_page_target_x = menu_cam_target_x;
global.menu_page_x = menu_page_x;

if (menu_state == MENU_STATE_SCROLLING)
{
    if (abs(menu_cam_x - menu_cam_target_x) < 0.5)
    {
        menu_state = (menu_cam_target_x == MENU_PAGE_2_X) ? MENU_STATE_PAGE2 : MENU_STATE_INIT;
    }
}

if (menu_state == MENU_STATE_INIT) current_page = 0;
else if (menu_state == MENU_STATE_PAGE2) current_page = 1;

if (back)
{
    if (menu_state == MENU_STATE_PAGE2)
    {
        cam_target_x = page_left_x;
        menu_cam_target_x = page_left_x;
        menu_state = MENU_STATE_SCROLLING;
    }
    else if (options_open)
    {
        options_open = false;
    }
}

btns = array_create(0);
with (obj_menu_button)
{
    var _visible = (button_page == 0 && other.menu_state == other.MENU_STATE_INIT) || (button_page == 1 && other.menu_state == other.MENU_STATE_PAGE2);
    if (_visible) array_push(btns, id);
}

if (array_length(btns) > 0)
{
    sel_index = clamp(sel_index, 0, array_length(btns) - 1);
    if (up) sel_index = (sel_index - 1 + array_length(btns)) mod array_length(btns);
    if (down) sel_index = (sel_index + 1) mod array_length(btns);

    if (ok)
    {
        with (btns[sel_index])
        {
            with (obj_menu_controller)
            {
                scr_menu_button_action(other.button_role);
            }
        }
    }
}

// Right-page level select logic remains controller-owned
var cx = menu_cam_x;
var mx_world = device_mouse_x_to_gui(0) + cx;
var my_world = device_mouse_y_to_gui(0);
var click = mouse_check_button_pressed(mb_left);

var hit_upgrade = (mx_world >= btn_upgrade.x && mx_world <= btn_upgrade.x + btn_upgrade.w && my_world >= btn_upgrade.y && my_world <= btn_upgrade.y + btn_upgrade.h);
var hit_play = (mx_world >= btn_play.x && mx_world <= btn_play.x + btn_play.w && my_world >= btn_play.y && my_world <= btn_play.y + btn_play.h);

var hit_level = array_create(array_length(level_btn), false);
if (menu_state == MENU_STATE_PAGE2)
{
    for (var li = 0; li < array_length(level_btn); li++)
    {
        var lb = level_btn[li];
        hit_level[li] = (mx_world >= lb.x && mx_world <= lb.x + lb.w && my_world >= lb.y && my_world <= lb.y + lb.h);

        if (click && hit_level[li] && lb.enabled)
        {
            sel_level = li;
            level_picked = true;
            global.menu_selected_room = lb.room;
            global.menu_selected_level_name = lb.name;
        }
    }

    if (click && level_picked && hit_upgrade)
    {
        global.in_menu = false;
        global.in_upgrade = true;
        room_goto(rm_upgrade);
    }

    if (click && level_picked && hit_play)
    {
        global.in_menu = false;
        global.GAME_STATE = "loading";
        global.in_loading = true;
        global.GAME_PAUSED = false;
        global.editor_on = false;
        global.next_room = global.menu_selected_room;
        room_goto(rm_loading);
    }
}

for (var gi = 0; gi < array_length(level_btn); gi++)
{
    var is_hov = (menu_state == MENU_STATE_PAGE2) && hit_level[gi];
    var is_sel = (menu_state == MENU_STATE_PAGE2) && level_picked && (sel_level == gi);
    glow_level[gi] = lerp(glow_level[gi], (is_hov || is_sel) ? 1 : 0, glow_speed);
}

glow_upgrade = lerp(glow_upgrade, (menu_state == MENU_STATE_PAGE2 && level_picked && hit_upgrade) ? 1 : 0, glow_speed);
glow_play = lerp(glow_play, (menu_state == MENU_STATE_PAGE2 && level_picked && hit_play) ? 1 : 0, glow_speed);
