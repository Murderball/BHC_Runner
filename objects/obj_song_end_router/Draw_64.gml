/// obj_song_end_router : Draw GUI
var dbg_on = false;
if (variable_global_exists("dbg_marker_keys_on") && global.dbg_marker_keys_on) dbg_on = true;
if (variable_global_exists("dbg_editor") && global.dbg_editor) dbg_on = true;
if (variable_global_exists("microprof") && is_struct(global.microprof) && variable_struct_exists(global.microprof, "draw_enabled") && global.microprof.draw_enabled) dbg_on = true;
if (!dbg_on) exit;

var snd_name = (is_real(current_sound) && current_sound >= 0) ? asset_get_name(current_sound) : "(none)";
var room_name = (is_real(target_room) && target_room >= 0) ? room_get_name(target_room) : "(none)";

var x = 16;
var y = 16;
var lh = 16;
var pad = 6;

var l1 = "Song Router";
var l2 = "armed: " + string(armed);
var l3 = "song: " + snd_name;
var l4 = "len_s: " + string_format(song_len_s, 0, 3) + " (stop_only=" + string(use_stop_only) + ")";
var l5 = "elapsed_s: " + string_format(elapsed_s, 0, 3);
var l6 = "target: " + room_name;

var bw = max(max(max(string_width(l1), string_width(l2)), max(string_width(l3), string_width(l4))), max(string_width(l5), string_width(l6))) + pad * 2;
var bh = (lh * 6) + pad * 2;

draw_set_alpha(0.65);
draw_set_color(c_black);
draw_rectangle(x, y, x + bw, y + bh, false);

draw_set_alpha(1);
draw_set_color(c_aqua);
draw_text(x + pad, y + pad + lh * 0, l1);
draw_set_color(c_white);
draw_text(x + pad, y + pad + lh * 1, l2);
draw_text(x + pad, y + pad + lh * 2, l3);
draw_text(x + pad, y + pad + lh * 3, l4);
draw_text(x + pad, y + pad + lh * 4, l5);
draw_text(x + pad, y + pad + lh * 5, l6);
