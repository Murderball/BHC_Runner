/// obj_post_fx : Step

if (surface_exists(application_surface)) {
    if (!appdraw_disabled) {
        application_surface_draw_enable(false);
        appdraw_disabled = true;
    }
} else if (appdraw_disabled) {
    application_surface_draw_enable(true);
    appdraw_disabled = false;
}
