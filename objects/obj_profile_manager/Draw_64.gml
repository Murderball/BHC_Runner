/// obj_profile_manager : Draw GUI
if (!variable_global_exists("profile_ui_active") || !global.profile_ui_active) exit;

var gw = display_get_gui_width();
var gh = display_get_gui_height();

var w = 520;
var h = 90;
var x = (gw - w) * 0.5;
var y = gh - h - 24;

draw_set_alpha(0.9);
draw_set_color(c_black);
draw_roundrect(x, y, x + w, y + h, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var title = (global.profile_ui_mode == "new") ? "Create Profile" : "Rename Profile";
draw_text(x + 12, y + 12, title + ": " + global.profile_ui_text);
draw_text(x + 12, y + 40, "Enter=Confirm  Esc=Cancel");
