/// obj_profile_manager : Step
if (!variable_global_exists("profile_ui_active") || !global.profile_ui_active) exit;

if (!variable_global_exists("profile_ui_text")) global.profile_ui_text = "";
if (!variable_global_exists("profile_ui_prev_keyboard_string")) global.profile_ui_prev_keyboard_string = "";

if (global.profile_ui_prev_keyboard_string == "") {
    keyboard_string = global.profile_ui_text;
}

global.profile_ui_text = string(keyboard_string);
global.profile_ui_prev_keyboard_string = global.profile_ui_text;

if (keyboard_check_pressed(vk_enter)) {
    var t = string_trim(global.profile_ui_text);
    if (global.profile_ui_mode == "new") {
        if (script_exists(scr_profiles_create)) scr_profiles_create(t);
    } else if (global.profile_ui_mode == "rename") {
        if (script_exists(scr_profiles_rename_active)) scr_profiles_rename_active(t);
    }
    if (script_exists(scr_profiles_save)) scr_profiles_save();
    global.profile_ui_active = false;
    global.profile_ui_mode = "";
    global.profile_ui_text = "";
    keyboard_string = "";
}

if (keyboard_check_pressed(vk_escape)) {
    global.profile_ui_active = false;
    global.profile_ui_mode = "";
    global.profile_ui_text = "";
    keyboard_string = "";
}
