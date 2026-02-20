/// obj_post_fx : Step

// Inert safety: never disable application-surface drawing.
fx_active = false;
fx_enabled = false;
application_surface_enable(true);
application_surface_draw_enable(true);
appdraw_disabled = false;
