/// obj_menu_controller : Step

// Camera safety
if (!variable_instance_exists(id, "cam") || cam == noone) cam = view_camera[0];
if (!variable_instance_exists(id, "cam_x")) cam_x = camera_get_view_x(cam);
if (!variable_instance_exists(id, "cam_y")) cam_y = camera_get_view_y(cam);

// Input
var ok    = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
var back  = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace);
var click = mouse_check_button_pressed(mb_left);

var up    = keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W"));
var down  = keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S"));
var left  = keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"));
var right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));

// Keyboard usage detection (marching ants)
var held_dir =
    keyboard_check(vk_up)    || keyboard_check(ord("W")) ||
    keyboard_check(vk_down)  || keyboard_check(ord("S")) ||
    keyboard_check(vk_left)  || keyboard_check(ord("A")) ||
    keyboard_check(vk_right) || keyboard_check(ord("D"));

var used_kb = held_dir || ok || back;
if (used_kb) kb_nav_timer = 90;
if (kb_nav_timer > 0) kb_nav_timer--;
kb_dash_phase = (kb_dash_phase + 1) & 15;

// Profile panel controls (isolated)
if (keyboard_check_pressed(vk_tab)) global.profile_panel_focus = !global.profile_panel_focus;

if (global.profile_panel_focus && !global.profile_ui_active)
{
    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
        if (variable_global_exists("profiles_data") && is_struct(global.profiles_data) && is_array(global.profiles_data.profiles)) {
            var _idx = -1;
            for (var _i = 0; _i < array_length(global.profiles_data.profiles); _i++) if (global.profiles_data.profiles[_i].id == global.profiles_data.active_profile_id) { _idx = _i; break; }
            if (_idx >= 0) {
                _idx = (_idx - 1 + array_length(global.profiles_data.profiles)) mod array_length(global.profiles_data.profiles);
                if (script_exists(scr_profiles_set_active)) scr_profiles_set_active(global.profiles_data.profiles[_idx].id);
                if (script_exists(scr_profiles_save)) scr_profiles_save();
            }
        }
    }
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
        if (variable_global_exists("profiles_data") && is_struct(global.profiles_data) && is_array(global.profiles_data.profiles)) {
            var _idx2 = -1;
            for (var _j = 0; _j < array_length(global.profiles_data.profiles); _j++) if (global.profiles_data.profiles[_j].id == global.profiles_data.active_profile_id) { _idx2 = _j; break; }
            if (_idx2 >= 0) {
                _idx2 = (_idx2 + 1) mod array_length(global.profiles_data.profiles);
                if (script_exists(scr_profiles_set_active)) scr_profiles_set_active(global.profiles_data.profiles[_idx2].id);
                if (script_exists(scr_profiles_save)) scr_profiles_save();
            }
        }
    }

    if (keyboard_check_pressed(ord("N"))) {
        global.profile_ui_active = true;
        global.profile_ui_mode = "new";
        global.profile_ui_text = "";
        global.profile_ui_prev_keyboard_string = "";
        keyboard_string = "";
    }
    if (keyboard_check_pressed(ord("R")) || keyboard_check_pressed(vk_enter)) {
        var _p = script_exists(scr_profiles_get_active) ? scr_profiles_get_active() : undefined;
        global.profile_ui_active = true;
        global.profile_ui_mode = "rename";
        global.profile_ui_text = is_struct(_p) ? string(_p.name) : "";
        global.profile_ui_prev_keyboard_string = "";
        keyboard_string = global.profile_ui_text;
    }

    var _diffs = ["easy", "normal", "hard"];
    var _didx = 1;
    for (var _di = 0; _di < array_length(_diffs); _di++) if (global.profile_view_difficulty == _diffs[_di]) { _didx = _di; break; }
    if (keyboard_check_pressed(vk_up)) _didx = (_didx - 1 + array_length(_diffs)) mod array_length(_diffs);
    if (keyboard_check_pressed(vk_down)) _didx = (_didx + 1) mod array_length(_diffs);
    global.profile_view_difficulty = _diffs[_didx];
}

if (variable_global_exists("menu_selected_room") && global.menu_selected_room != noone) global.profile_view_level_key = room_get_name(global.menu_selected_room);
// Mouse WORLD coords
var cx = camera_get_view_x(cam);
var cy = camera_get_view_y(cam);
var mx = device_mouse_x_to_gui(0) + cx;
var my = device_mouse_y_to_gui(0) + cy;

// Smooth camera
cam_x = lerp(cam_x, cam_target_x, scroll_lerp);
cam_x = clamp(cam_x, min_cam_x, max_cam_x);
cam_y = clamp(cam_y, min_cam_y, max_cam_y);
camera_set_view_pos(cam, cam_x, cam_y);

// Hit checks (left menu)
var hit_start   = (mx >= btn_start.x   && mx <= btn_start.x   + btn_start.w   && my >= btn_start.y   && my <= btn_start.y   + btn_start.h);
var hit_story   = (mx >= btn_story.x   && mx <= btn_story.x   + btn_story.w   && my >= btn_story.y   && my <= btn_story.y   + btn_story.h);
var hit_arcade  = (mx >= btn_arcade.x  && mx <= btn_arcade.x  + btn_arcade.w  && my >= btn_arcade.y  && my <= btn_arcade.y  + btn_arcade.h);
var hit_options = (mx >= btn_options.x && mx <= btn_options.x + btn_options.w && my >= btn_options.y && my <= btn_options.y + btn_options.h);
var hit_game    = (mx >= btn_game.x    && mx <= btn_game.x    + btn_game.w    && my >= btn_game.y    && my <= btn_game.y    + btn_game.h);
var hit_exit    = (mx >= btn_exit.x    && mx <= btn_exit.x    + btn_exit.w    && my >= btn_exit.y    && my <= btn_exit.y    + btn_exit.h);

var hit_options_slider_track = false;
var hit_options_slider_knob = false;

// Left-page difficulty hits (BEFORE pan)
var hit_easyL   = (mx >= btn_easyL.x   && mx <= btn_easyL.x   + btn_easyL.w   && my >= btn_easyL.y   && my <= btn_easyL.y   + btn_easyL.h);
var hit_normalL = (mx >= btn_normalL.x && mx <= btn_normalL.x + btn_normalL.w && my >= btn_normalL.y && my <= btn_normalL.y + btn_normalL.h);
var hit_hardL   = (mx >= btn_hardL.x   && mx <= btn_hardL.x   + btn_hardL.w   && my >= btn_hardL.y   && my <= btn_hardL.y   + btn_hardL.h);

// Right page hits
var hit_back = (mx >= btn_back.x && mx <= btn_back.x + btn_back.w && my >= btn_back.y && my <= btn_back.y + btn_back.h);

// Upgrade + Play hits
var hit_upgrade = (mx >= btn_upgrade.x && mx <= btn_upgrade.x + btn_upgrade.w && my >= btn_upgrade.y && my <= btn_upgrade.y + btn_upgrade.h);
var hit_play    = (mx >= btn_play.x    && mx <= btn_play.x    + btn_play.w    && my >= btn_play.y    && my <= btn_play.y    + btn_play.h);

// NEW: Level hits (right page)
var hit_level = array_create(array_length(level_btn), false);
if (menu_state == 2) {
    for (var li = 0; li < array_length(level_btn); li++) {
        var lb = level_btn[li];
        hit_level[li] = (mx >= lb.x && mx <= lb.x + lb.w && my >= lb.y && my <= lb.y + lb.h);
    }
}

// --------------------------------------------------
// Helpers
// --------------------------------------------------
function apply_diff_from_index(_idx)
{
    var d = "normal";
    if (_idx == 0) d = "easy";
    else if (_idx == 2) d = "hard";
    global.DIFFICULTY = d;
    global.difficulty = d;
}

function reset_right_page_state()
{
    // Level must be chosen before character select is active
    level_picked = false;
    sel_level = -1;

    // Reset character pick path
    char_picked = false;
    sel_char = -1;
    cs_focus_upgrade = false;
    cs_focus_play = false;
    cs_focus_back = false;
}

// --------------------------------------------------
// STATE MACHINE
// --------------------------------------------------
switch (menu_state)
{
    case 0: // left menu
    {
        if (back)
        {
            if (options_open) options_open = false;
            else if (arcade_diff_open) arcade_diff_open = false;
            else if (start_open) { start_open = false; if (sel_main > 0) sel_main = 0; }
        }

        // -----------------------------
        // OPTIONS submenu (EXIT)
        // -----------------------------
        if (options_open)
        {
            if (used_kb && sel_opt < 0) sel_opt = 0;

            if (kb_nav_timer <= 0)
            {
                if (hit_game) sel_opt = 0;
                else if (hit_exit) sel_opt = 1;
            }

            if (!menu_game_adjust)
            {
                if (up) sel_opt = (sel_opt - 1 + 2) mod 2;
                if (down) sel_opt = (sel_opt + 1) mod 2;
            }

            if (sel_opt == 0 && right && !menu_game_adjust) menu_game_adjust = true;

            ui_mouse_x = mx;
            ui_mouse_y = my;
            ui_input_left = left;
            ui_input_right = right;
            var _panel_state = scr_ui_master_volume_panel_update(btn_options.x, btn_options.y, btn_options.w, btn_options.h, sel_opt == 0);
            hit_options_slider_track = _panel_state.hit_track;
            hit_options_slider_knob = _panel_state.hit_knob;

            if (mouse_check_button_pressed(mb_left) && (hit_options_slider_track || hit_options_slider_knob))
            {
                sel_opt = 0;
                menu_game_adjust = true;
                options_slider_drag = true;
            }

            if (click)
            {
                if (hit_exit)
                {
                    sel_opt = 1;
                    game_end();
                }
                else if (!hit_game && !hit_options_slider_track && !hit_options_slider_knob)
                {
                    options_open = false;
                    menu_game_adjust = false;
                    options_slider_drag = false;
                    sel_opt = -1;
                }
            }

            if (ok)
            {
                if (sel_opt < 0) sel_opt = 0;

                if (sel_opt == 0)
                {
                    menu_game_adjust = !menu_game_adjust;
                }
                else
                {
                    game_end();
                }
            }

            if (back)
            {
                if (menu_game_adjust) menu_game_adjust = false;
                else
                {
                    options_open = false;
                    menu_game_open = false;
                    options_slider_drag = false;
                    sel_opt = -1;
                }
            }

            break;
        }

        // -----------------------------
        // Arcade difficulty submenu (LEFT PAGE — before pan)
        // -----------------------------
        if (arcade_diff_open)
        {
            if (kb_nav_timer <= 0)
            {
                if (hit_easyL) sel_diff = 0;
                else if (hit_normalL) sel_diff = 1;
                else if (hit_hardL) sel_diff = 2;
            }

            // Click on diff chooses diff AND pans to right page
            if (click)
            {
                var clicked_any = false;

                if (hit_easyL)   { clicked_any = true; sel_diff = 0; }
                else if (hit_normalL) { clicked_any = true; sel_diff = 1; }
                else if (hit_hardL)   { clicked_any = true; sel_diff = 2; }

                if (clicked_any)
                {
                    apply_diff_from_index(sel_diff);

                    global.game_mode = "arcade";
                    arcade_diff_open = false;

                    reset_right_page_state();

                    cam_target_x = page_right_x;
                    right_target_state = 2;
                    menu_state = 1;
                }
                else
                {
                    sel_diff = -1;
                    arcade_diff_open = false;
                }
                break;
            }

            // Keyboard nav
            if (used_kb && sel_diff < 0) sel_diff = 1;
            if (up && sel_diff >= 0)   sel_diff = (sel_diff - 1 + 3) mod 3;
            if (down && sel_diff >= 0) sel_diff = (sel_diff + 1) mod 3;

            if (ok)
            {
                if (sel_diff < 0) break;

                apply_diff_from_index(sel_diff);

                global.game_mode = "arcade";
                arcade_diff_open = false;

                reset_right_page_state();

                cam_target_x = page_right_x;
                right_target_state = 2;
                menu_state = 1;
            }

            break;
        }

        // -----------------------------
        // Main menu selection
        // -----------------------------
        var count = start_open ? 4 : 2;

        if (kb_nav_timer <= 0)
        {
            if (start_open)
            {
                if (hit_start)   sel_main = 0;
                else if (hit_story)   sel_main = 1;
                else if (hit_arcade)  sel_main = 2;
                else if (hit_options) sel_main = 3;
            }
            else
            {
                if (hit_start)   sel_main = 0;
                else if (hit_options) sel_main = 1;
            }
        }

        if (used_kb && sel_main < 0) sel_main = 0;

        if (up)   sel_main = (sel_main - 1 + count) mod count;
        if (down) sel_main = (sel_main + 1) mod count;

        // CLICK behavior
        if (click)
        {
            var clicked_any = false;

            if (!start_open)
            {
                if (hit_start)   { clicked_any = true; start_open = true; sel_main = 1; }
                else if (hit_options) { clicked_any = true; options_open = true; menu_game_open = false; sel_opt = 0; }
            }
            else
            {
                if (hit_start) { clicked_any = true; start_open = false; sel_main = 0; }
                else if (hit_story)
                {
                    clicked_any = true;
                    global.game_mode = "story";

                    global.DIFFICULTY = "normal";
                    global.difficulty = "normal";

                    reset_right_page_state();

                    cam_target_x = page_right_x;
                    right_target_state = 2;
                    menu_state = 1;
                }
                else if (hit_arcade)
                {
                    clicked_any = true;

                    global.game_mode = "arcade";
                    arcade_diff_open = true;

                    var d = string_lower(string(global.difficulty));
                    if (d == "easy") sel_diff = 0;
                    else if (d == "hard") sel_diff = 2;
                    else sel_diff = 1;
                }
                else if (hit_options)
                {
                    clicked_any = true;
                    options_open = true;
                    menu_game_open = false;
                    sel_opt = 0;
                }
            }

            if (!clicked_any)
            {
                sel_main = -1;
                sel_opt = -1;
            }

            break;
        }

        // OK (keyboard)
        if (ok)
        {
            if (sel_main < 0) break;

            if (!start_open)
            {
                if (sel_main == 0) { start_open = true; sel_main = 1; }
                else { options_open = true; menu_game_open = false; sel_opt = 0; }
            }
            else
            {
                if (sel_main == 0) { start_open = false; sel_main = 0; }
                else if (sel_main == 1)
                {
                    global.game_mode = "story";
                    global.DIFFICULTY = "normal";
                    global.difficulty = "normal";

                    reset_right_page_state();

                    cam_target_x = page_right_x;
                    right_target_state = 2;
                    menu_state = 1;
                }
                else if (sel_main == 2)
                {
                    global.game_mode = "arcade";
                    arcade_diff_open = true;

                    var d2 = string_lower(string(global.difficulty));
                    if (d2 == "easy") sel_diff = 0;
                    else if (d2 == "hard") sel_diff = 2;
                    else sel_diff = 1;
                }
                else if (sel_main == 3)
                {
                    options_open = true;
                    menu_game_open = false;
                    sel_opt = 0;
                }
            }
        }

        // quick right to go into story/arcade when submenu open
        if (right && start_open)
        {
            if (sel_main == 1)
            {
                global.game_mode = "story";
                global.DIFFICULTY = "normal";
                global.difficulty = "normal";

                reset_right_page_state();

                cam_target_x = page_right_x;
                right_target_state = 2;
                menu_state = 1;
            }
            if (sel_main == 2)
            {
                global.game_mode = "arcade";
                arcade_diff_open = true;
            }
        }
    }
    break;

    case 1: // scrolling
    {
        if (back) cam_target_x = page_left_x;

        if (abs(cam_x - cam_target_x) < 1)
        {
            cam_x = cam_target_x;
            camera_set_view_pos(cam, cam_x, cam_y);

            if (cam_target_x == page_right_x) menu_state = right_target_state;
            else menu_state = 0;
        }
    }
    break;

    case 2: // RIGHT PAGE: Level Select first -> then Character Select
    {
        // Back to left
        if (back || (click && hit_back))
        {
            // clear right-side focus/picks
            char_picked = false;
            cs_focus_upgrade = false;
            cs_focus_play = false;
            cs_focus_back = false;

            level_picked = false;
            sel_level = -1;

            cam_target_x = page_left_x;
            menu_state = 1;
            break;
        }

        // CLICK behavior
        if (click)
        {
            var clicked_any = false;

            // 1) LEVEL CLICK (always available on right page)
            for (var li2 = 0; li2 < array_length(level_btn); li2++)
            {
                if (hit_level[li2])
                {
                    var L = level_btn[li2];

                    // placeholders are NOT selectable
                    if (L.enabled)
                    {
                        clicked_any = true;

                        sel_level = li2;
                        level_picked = true;

                        global.menu_selected_room = L.room;
                        global.menu_selected_level_name = L.name;

                        // choosing a level resets character pick path
                        char_picked = false;
                        sel_char = -1;
                        cs_focus_upgrade = false;
                        cs_focus_play = false;
                        cs_focus_back = false;
                    }
                    else
                    {
                        clicked_any = true;
                        // do nothing (placeholder)
                    }
                    break;
                }
            }

            // 2) If level is picked, allow character select + upgrade/play
            if (level_picked)
            {
                // Upgrade click (only when revealed)
                if (char_picked && hit_upgrade)
                {
                    clicked_any = true;

                    global.upgrade_char_id = picked_char_id;
                    global.char_id = global.upgrade_char_id;

                    if (variable_global_exists("menu_music_handle") && global.menu_music_handle >= 0) {
                        audio_stop_sound(global.menu_music_handle);
                        global.menu_music_handle = -1;
                    }

                    global.in_menu = false;
                    global.in_upgrade = true;
                    room_goto(rm_upgrade);
                    break;
                }

                // LETS GO click (only when revealed)
                if (char_picked && hit_play)
                {
                    clicked_any = true;

                    global.char_id = picked_char_id;

                    global.in_menu = false;
                    global.GAME_STATE = "loading";
                    global.in_loading = true;
                    global.GAME_PAUSED = false;
                    global.editor_on = false;
                    global.play_requested = true;

                    if (variable_global_exists("menu_music_handle") && global.menu_music_handle >= 0) {
                        audio_stop_sound(global.menu_music_handle);
                        global.menu_music_handle = -1;
                    }

                    // NEW: route to selected level/boss
                    global.next_room = global.menu_selected_room;
                    room_goto(rm_loading);
                    break;
                }

                // Character click = PICK ONLY (never start)
                for (var j = 0; j < array_length(char_btn); j++)
                {
                    var bb = char_btn[j];
                    if (mx >= bb.x && mx <= bb.x + bb.w && my >= bb.y && my <= bb.y + bb.h)
                    {
                        clicked_any = true;

                        sel_char = bb.id;
                        picked_char_id = sel_char;
                        global.char_id = picked_char_id;

                        char_picked = true;
                        cs_focus_upgrade = false;
                        cs_focus_play = false;
                        cs_focus_back = false;

                        break;
                    }
                }

                // Click-off deselect (character only)
                if (!clicked_any)
                {
                    sel_char = -1;
                    cs_focus_back = false;
                    cs_focus_upgrade = false;
                    cs_focus_play = false;
                    break;
                }
            }

            // If level NOT picked and you click empty space, do nothing
        }

        // Keyboard focus: Back
        if (cs_focus_back)
        {
            if (right) cs_focus_back = false;
            if (ok) { cs_focus_back = false; cam_target_x = page_left_x; menu_state = 1; }
            break;
        }

        // Keyboard focus: Upgrade
        if (cs_focus_upgrade)
        {
            if (right) { cs_focus_upgrade = false; cs_focus_play = true; }
            if (up) cs_focus_upgrade = false;

            if (ok)
            {
                if (!level_picked || !char_picked) break;

                global.upgrade_char_id = picked_char_id;
                global.char_id = global.upgrade_char_id;

                if (variable_global_exists("menu_music_handle") && global.menu_music_handle >= 0) {
                    audio_stop_sound(global.menu_music_handle);
                    global.menu_music_handle = -1;
                }

                global.in_menu = false;
                global.in_upgrade = true;
                room_goto(rm_upgrade);
            }
            break;
        }

        // Keyboard focus: Lets Go
        if (cs_focus_play)
        {
            if (left) { cs_focus_play = false; cs_focus_upgrade = true; }
            if (up) cs_focus_play = false;

            if (ok)
            {
                if (!level_picked || !char_picked) break;

                global.char_id = picked_char_id;

                global.in_menu = false;
                global.GAME_STATE = "loading";
                global.in_loading = true;
                global.GAME_PAUSED = false;
                global.editor_on = false;
                global.play_requested = true;

                if (variable_global_exists("menu_music_handle") && global.menu_music_handle >= 0) {
                    audio_stop_sound(global.menu_music_handle);
                    global.menu_music_handle = -1;
                }

                global.next_room = global.menu_selected_room;
                room_goto(rm_loading);
            }
            break;
        }

        // Character keyboard grid nav only after level picked
        if (level_picked)
        {
            if (used_kb && sel_char < 0) sel_char = 0;

            if (left)
            {
                if (sel_char == 0 || sel_char == 2) cs_focus_back = true;
                else if (sel_char == 1) sel_char = 0;
                else if (sel_char == 3) sel_char = 2;
            }
            if (right)
            {
                if (sel_char == 0) sel_char = 1;
                else if (sel_char == 2) sel_char = 3;
            }
            if (up)
            {
                if (sel_char >= 2) sel_char -= 2;
            }
            if (down)
            {
                if (char_picked && (sel_char == 2 || sel_char == 3))
                {
                    cs_focus_upgrade = true;
                }
                else
                {
                    if (sel_char <= 1) sel_char += 2;
                }
            }

            // Mouse hover selection (highlight only)
            if (kb_nav_timer <= 0 && sel_char >= 0)
            {
                for (var i = 0; i < array_length(char_btn); i++)
                {
                    var b = char_btn[i];
                    if (mx >= b.x && mx <= b.x + b.w && my >= b.y && my <= b.y + b.h) {
                        sel_char = b.id;
                    }
                }
            }

            // OK on character = PICK ONLY (never start)
            if (ok && !cs_focus_upgrade && !cs_focus_play && !cs_focus_back)
            {
                if (sel_char < 0) break;

                picked_char_id = sel_char;
                global.char_id = picked_char_id;

                char_picked = true;
            }
        }
    }
    break;
}

// --------------------------------------------------
// Glow update
// --------------------------------------------------
var gs = glow_speed;

// Left menu glows
var hov_start   = (menu_state == 0) && hit_start;
var hov_story   = (menu_state == 0) && start_open && hit_story;
var hov_arcade  = (menu_state == 0) && start_open && hit_arcade;
var hov_options = (menu_state == 0) && hit_options;
var hov_game    = (menu_state == 0) && options_open && !menu_game_open && hit_game;
var hov_exit    = (menu_state == 0) && options_open && !menu_game_open && hit_exit;

// Left-page diff hovers
var hov_easyL   = (menu_state == 0) && arcade_diff_open && hit_easyL;
var hov_normalL = (menu_state == 0) && arcade_diff_open && hit_normalL;
var hov_hardL   = (menu_state == 0) && arcade_diff_open && hit_hardL;

// Right-page hovers
var hov_back = (menu_state == 2) && hit_back;

// NEW: level hover (and selected stays glowing a bit)
for (var gi = 0; gi < array_length(level_btn); gi++)
{
    var is_hov = (menu_state == 2) && hit_level[gi];
    var is_sel = (menu_state == 2) && level_picked && (sel_level == gi);
    glow_level[gi] = lerp(glow_level[gi], (is_hov || is_sel) ? 1 : 0, gs);
}

// Character hovers (ONLY when level picked)
var hov0=false, hov1=false, hov2=false, hov3=false;
if (menu_state == 2 && level_picked && sel_char >= 0) {
    var b0 = char_btn[0]; hov0 = (mx>=b0.x && mx<=b0.x+b0.w && my>=b0.y && my<=b0.y+b0.h);
    var b1 = char_btn[1]; hov1 = (mx>=b1.x && mx<=b1.x+b1.w && my>=b1.y && my<=b1.y+b1.h);
    var b2 = char_btn[2]; hov2 = (mx>=b2.x && mx<=b2.x+b2.w && my>=b2.y && my<=b2.y+b2.h);
    var b3 = char_btn[3]; hov3 = (mx>=b3.x && mx<=b3.x+b3.w && my>=b3.y && my<=b3.y+b3.h);
}

var hov_upgrade = (menu_state == 2) && level_picked && char_picked && hit_upgrade;
var hov_play    = (menu_state == 2) && level_picked && char_picked && hit_play;

glow_start   = lerp(glow_start,   hov_start   ? 1 : 0, gs);
glow_story   = lerp(glow_story,   hov_story   ? 1 : 0, gs);
glow_arcade  = lerp(glow_arcade,  hov_arcade  ? 1 : 0, gs);
glow_options = lerp(glow_options, hov_options ? 1 : 0, gs);
glow_game    = lerp(glow_game,    hov_game    ? 1 : 0, gs);
glow_exit    = lerp(glow_exit,    hov_exit    ? 1 : 0, gs);

glow_easyL   = lerp(glow_easyL,   hov_easyL   ? 1 : 0, gs);
glow_normalL = lerp(glow_normalL, hov_normalL ? 1 : 0, gs);
glow_hardL   = lerp(glow_hardL,   hov_hardL   ? 1 : 0, gs);

glow_back    = lerp(glow_back,    hov_back ? 1 : 0, gs);

glow_char0   = lerp(glow_char0,   hov0 ? 1 : 0, gs);
glow_char1   = lerp(glow_char1,   hov1 ? 1 : 0, gs);
glow_char2   = lerp(glow_char2,   hov2 ? 1 : 0, gs);
glow_char3   = lerp(glow_char3,   hov3 ? 1 : 0, gs);

glow_upgrade = lerp(glow_upgrade, hov_upgrade ? 1 : 0, gs);
glow_play    = lerp(glow_play,    hov_play    ? 1 : 0, gs);
