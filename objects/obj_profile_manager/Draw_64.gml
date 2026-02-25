/// obj_profile_manager : Draw GUI
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

if (!sprite_exists(spr_leaderboard)) exit;

var panel_w = 520;
var panel_h = 260;
var panel_x = (gui_w - panel_w) * 0.5;
var panel_y = max(16, gui_h - panel_h - 24);

draw_set_alpha(0.9);
draw_set_color(c_black);
draw_roundrect(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_text(panel_x + 12, panel_y + 12, "Leaderboard");

var active_profile = script_exists(scr_profiles_get_active) ? scr_profiles_get_active() : undefined;
var level_key = room_get_name(room);
var difficulty_key = variable_global_exists("difficulty") ? string_lower(string(global.difficulty)) : "normal";
var leaderboard_rows = script_exists(scr_profiles_get_top10) ? scr_profiles_get_top10(level_key, difficulty_key) : undefined;

if (!is_array(leaderboard_rows) || array_length(leaderboard_rows) <= 0) {
    for (var row_i = 0; row_i < 10; row_i++) {
        draw_text(panel_x + 12, panel_y + 40 + row_i * 18, string(row_i + 1) + ". ---");
    }
} else {
    var top_n = min(10, array_length(leaderboard_rows));
    for (var row_j = 0; row_j < top_n; row_j++) {
        var row_txt = string(row_j + 1) + ". ---";
        if (is_struct(leaderboard_rows[row_j])) {
            var row_data = leaderboard_rows[row_j];
            var row_name = variable_struct_exists(row_data, "name") ? string(row_data.name) : "Player";
            var row_acc = variable_struct_exists(row_data, "accuracy") ? real(row_data.accuracy) : 0;
            if (!is_real(row_acc) || row_acc != row_acc) row_acc = 0;
            row_acc = clamp(row_acc, 0, 1);

            var numer = row_acc * 100;
            var denom = 1;
            if (denom <= 0) denom = 1;
            var acc_pct = numer / denom;
            row_txt = string(row_j + 1) + ". " + row_name + "  " + string_format(acc_pct, 0, 2) + "%";
        }
        draw_text(panel_x + 12, panel_y + 40 + row_j * 18, row_txt);
    }

    for (var row_k = top_n; row_k < 10; row_k++) {
        draw_text(panel_x + 12, panel_y + 40 + row_k * 18, string(row_k + 1) + ". ---");
    }
}

if (variable_global_exists("profile_ui_active") && global.profile_ui_active) {
    var ui_mode = variable_global_exists("profile_ui_mode") ? string(global.profile_ui_mode) : "";
    var ui_text = variable_global_exists("profile_ui_text") ? string(global.profile_ui_text) : "";
    var ui_title = (ui_mode == "new") ? "Create Profile" : "Rename Profile";

    var overlay_w = panel_w;
    var overlay_h = 90;
    var overlay_x = panel_x;
    var overlay_y = max(16, panel_y - overlay_h - 12);

    draw_set_alpha(0.92);
    draw_set_color(c_black);
    draw_roundrect(overlay_x, overlay_y, overlay_x + overlay_w, overlay_y + overlay_h, false);
    draw_set_alpha(1);
    draw_set_color(c_white);

    draw_text(overlay_x + 12, overlay_y + 12, ui_title + ": " + ui_text);
    draw_text(overlay_x + 12, overlay_y + 40, "Enter=Confirm  Esc=Cancel");

    if (is_struct(active_profile) && variable_struct_exists(active_profile, "name")) {
        draw_text(overlay_x + 12, overlay_y + 62, "Active: " + string(active_profile.name));
    } else {
        draw_text(overlay_x + 12, overlay_y + 62, "Active: ---");
    }
}
