/// obj_post_fx : Create

persistent = true;

// Keep object inert; project should not rely on app-surface post FX.
fx_active = false;
fx_enabled = false;
appdraw_disabled = false;

application_surface_enable(true);
application_surface_draw_enable(true);
