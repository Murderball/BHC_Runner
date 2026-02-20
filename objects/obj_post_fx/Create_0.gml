/// obj_post_fx : Create

persistent = true;

fx_enabled = true;
appdraw_disabled = false;

u_time_s   = shader_get_uniform(shd_bpm_dual_pulse, "u_time_s");
u_spb      = shader_get_uniform(shd_bpm_dual_pulse, "u_spb");
u_teal_key = shader_get_uniform(shd_bpm_dual_pulse, "u_teal_key");
u_pink_key = shader_get_uniform(shd_bpm_dual_pulse, "u_pink_key");
u_tol      = shader_get_uniform(shd_bpm_dual_pulse, "u_tol");
u_str_teal = shader_get_uniform(shd_bpm_dual_pulse, "u_str_teal");
u_str_pink = shader_get_uniform(shd_bpm_dual_pulse, "u_str_pink");
u_decay    = shader_get_uniform(shd_bpm_dual_pulse, "u_decay");

fx_tol           = 0.30;
fx_decay         = 8.0;
fx_teal_strength = 0.35;
fx_pink_strength = 0.35;
