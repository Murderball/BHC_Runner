/// obj_score_manager: Draw GUI
if (!variable_global_exists("DEBUG_SCORE") || !global.DEBUG_SCORE) exit;
if (!variable_global_exists("score_state") || !is_struct(global.score_state)) exit;

var s = scr_score_get_snapshot();

var _x = 16;
var _y = display_get_gui_height() * 0.40;

var _line = "SCORE: " + string(s.score_total)
          + "\nCOMBO: " + string(s.combo) + " (MAX " + string(s.max_combo) + ")"
          + "\nMULT: " + string_format(s.multiplier, 1, 2) + "x"
          + " (T " + string_format(s.multiplier_target, 1, 2) + "x)"
          + "\nACC: " + string_format(s.accuracy_percent, 1, 2) + "%"
          + " | ROLL: " + string_format(s.rolling_accuracy * 100.0, 1, 2) + "%"
          + "\nP/G/B/M: "
          + string(s.count_perfect) + "/"
          + string(s.count_good) + "/"
          + string(s.count_bad) + "/"
          + string(s.count_miss)
          + "\nHIT/TOTAL: " + string(s.notes_hit) + "/" + string(s.notes_total);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
draw_text(_x, _y, _line);
