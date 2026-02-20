/// obj_post_fx : Draw End

if (!surface_exists(application_surface)) exit;

application_surface_draw_enable(false);
draw_clear_alpha(c_black, 1);

var px = view_xport[0];
var py = view_yport[0];
var pw = view_wport[0];
var ph = view_hport[0];

if (pw <= 0 || ph <= 0) {
    px = 0;
    py = 0;
    pw = display_get_gui_width();
    ph = display_get_gui_height();
}

var t = script_exists(scr_chart_time) ? scr_chart_time() : 0.0;

var spb = 60.0 / 140.0;
if (variable_global_exists("SEC_PER_BEAT") && is_real(global.SEC_PER_BEAT) && (global.SEC_PER_BEAT > 0)) {
    spb = global.SEC_PER_BEAT;
} else if (variable_global_exists("BPM") && is_real(global.BPM) && (global.BPM > 0)) {
    spb = 60.0 / global.BPM;
}

shader_set(shd_bpm_dual_pulse);
shader_set_uniform_f(u_time_s, t);
shader_set_uniform_f(u_spb, spb);
shader_set_uniform_f(u_tol, fx_tol);
shader_set_uniform_f(u_decay, fx_decay);
shader_set_uniform_f(u_str_teal, fx_teal_strength);
shader_set_uniform_f(u_str_pink, fx_pink_strength);
shader_set_uniform_f(u_teal_key, teal_key_r, teal_key_g, teal_key_b);
shader_set_uniform_f(u_pink_key, pink_key_r, pink_key_g, pink_key_b);

draw_surface_stretched(application_surface, px, py, pw, ph);
shader_reset();
