/// obj_post_fx : Create

persistent = true;
application_surface_draw_enable(false);

u_time_s     = shader_get_uniform(shd_bpm_dual_pulse, "u_time_s");
u_spb        = shader_get_uniform(shd_bpm_dual_pulse, "u_spb");
u_tol        = shader_get_uniform(shd_bpm_dual_pulse, "u_tol");
u_decay      = shader_get_uniform(shd_bpm_dual_pulse, "u_decay");
u_str_teal   = shader_get_uniform(shd_bpm_dual_pulse, "u_str_teal");
u_str_pink   = shader_get_uniform(shd_bpm_dual_pulse, "u_str_pink");
u_teal_key   = shader_get_uniform(shd_bpm_dual_pulse, "u_teal_key");
u_pink_key   = shader_get_uniform(shd_bpm_dual_pulse, "u_pink_key");

fx_tol           = 0.30;
fx_decay         = 8.0;
fx_teal_strength = 0.40;
fx_pink_strength = 0.40;

teal_key_r = 0.184;
teal_key_g = 0.851;
teal_key_b = 0.875;

pink_key_r = 1.000;
pink_key_g = 0.035;
pink_key_b = 0.910;
