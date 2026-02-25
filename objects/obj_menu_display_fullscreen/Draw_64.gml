/// obj_menu_display_fullscreen : Draw GUI
if (instance_exists(obj_menu_controller)) exit;

if (script_exists(scr_draw_leaderboard_panel)) {
    var _spr = asset_get_index("spr_leaderboard");
    var _pw = 420;
    if (_spr >= 0) _pw = sprite_get_width(_spr);
    var _px = display_get_gui_width() - _pw - 32;
    var _py = 32;
    var _level = variable_global_exists("profile_view_level_key") ? global.profile_view_level_key : "rm_level01";
    var _diff = variable_global_exists("profile_view_difficulty") ? global.profile_view_difficulty : "normal";
    scr_draw_leaderboard_panel(_px, _py, _pw, 420, "right", _level, _diff, true);
}
