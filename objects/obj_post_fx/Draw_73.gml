/// obj_post_fx : Draw End

if (!surface_exists(application_surface)) {
    if (appdraw_disabled) {
        application_surface_draw_enable(true);
        appdraw_disabled = false;
    }
    exit;
}

var px = view_xport[0];
var py = view_yport[0];
var pw = view_wport[0];
var ph = view_hport[0];

var apply_fx = fx_enabled;

if (variable_global_exists("in_menu") && global.in_menu) apply_fx = false;
if (variable_global_exists("in_loading") && global.in_loading) apply_fx = false;

var rn = room_get_name(room);
if (room == rm_menu || room == rm_upgrade || room == rm_loading) apply_fx = false;
if (string_pos("menu", rn) > 0 || string_pos("upgrade", rn) > 0 || string_pos("loading", rn) > 0) apply_fx = false;

if (!apply_fx) {
    draw_surface_stretched(application_surface, px, py, pw, ph);
    exit;
}

var shader_ok = (shd_bpm_dual_pulse != -1)
    && (u_time_s != -1)
    && (u_spb != -1)
    && (u_teal_key != -1)
    && (u_pink_key != -1)
    && (u_tol != -1)
    && (u_str_teal != -1)
    && (u_str_pink != -1)
    && (u_decay != -1);

if (!shader_ok) {
    draw_surface_stretched(application_surface, px, py, pw, ph);
    exit;
}

var t = script_exists(scr_chart_time) ? scr_chart_time() : 0.0;

var spb = 60.0 / 140.0;
if (variable_global_exists("SEC_PER_BEAT") && is_real(global.SEC_PER_BEAT) && global.SEC_PER_BEAT > 0) {
    spb = global.SEC_PER_BEAT;
} else if (variable_global_exists("BPM") && is_real(global.BPM) && global.BPM > 0) {
    spb = 60.0 / global.BPM;
}

shader_set(shd_bpm_dual_pulse);
shader_set_uniform_f(u_time_s, t);
shader_set_uniform_f(u_spb, spb);
shader_set_uniform_f(u_teal_key, 0.1843137, 0.8509804, 0.8745098);
shader_set_uniform_f(u_pink_key, 1.0, 0.0352941, 0.9098039);
shader_set_uniform_f(u_tol, fx_tol);
shader_set_uniform_f(u_str_teal, fx_teal_strength);
shader_set_uniform_f(u_str_pink, fx_pink_strength);
shader_set_uniform_f(u_decay, fx_decay);

draw_surface_stretched(application_surface, px, py, pw, ph);
shader_reset();
