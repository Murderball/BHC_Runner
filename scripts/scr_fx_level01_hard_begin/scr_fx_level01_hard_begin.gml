/// scr_fx_level01_hard_begin()
/// Called by TL_Visual_Hard layer begin script.

var d = "normal";
if (variable_global_exists("difficulty")) d = string_lower(string(global.difficulty));
else if (variable_global_exists("DIFFICULTY")) d = string_lower(string(global.DIFFICULTY));

if (!(room == rm_level01 && d == "hard")) exit;

// Activate shader
shader_set(shd_bpm_dual_pulse);

// Time + seconds-per-beat
var t = (script_exists(scr_chart_time)) ? scr_chart_time() : 0.0;
var spb = (variable_global_exists("SEC_PER_BEAT") && is_real(global.SEC_PER_BEAT) && global.SEC_PER_BEAT > 0)
    ? global.SEC_PER_BEAT
    : (60.0 / 165.0);

// Uniforms
shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_time_s"), t);
shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_spb"), spb);

// MAKE IT OBVIOUS (debug strong settings)
// Once you see it, dial these back.
shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_tol"), 1.25);
shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_str_blue"), 1.25);
shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_str_pink"), 1.25);
shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_decay"), 6.0);

// Key colors (0..1) — tweak later
shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_blue_key"), 0.30, 0.75, 1.00);
shader_set_uniform_f(shader_get_uniform(shd_bpm_dual_pulse, "u_pink_key"), 1.00, 0.30, 0.85);