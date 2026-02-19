function scr_bg_prewarm_step(_perFrame)
{
    // If prewarm wasn't started, do nothing safely
    if (!variable_global_exists("bg_prewarm_done")) return;
    if (global.bg_prewarm_done) return;

    // Ensure the surface handle global exists before reading it
    if (!variable_global_exists("bg_prewarm_surf")) global.bg_prewarm_surf = -1;

    // Create tiny surface to “touch” textures
    if (!surface_exists(global.bg_prewarm_surf)) {
        global.bg_prewarm_surf = surface_create(32, 32);
    }

    // If surface creation failed, stop trying (avoids loops/spikes)
    if (!surface_exists(global.bg_prewarm_surf)) {
        global.bg_prewarm_done = true;
        return;
    }

    surface_set_target(global.bg_prewarm_surf);
    draw_clear_alpha(c_black, 0);

    var count = 0;
    while (count < _perFrame && global.bg_prewarm_i < array_length(global.bg_prewarm_queue))
    {
        var spr = global.bg_prewarm_queue[global.bg_prewarm_i];
        global.bg_prewarm_i++;

        draw_sprite(spr, 0, 0, 0);
        count++;
    }

    surface_reset_target();

    // Finished?
    if (global.bg_prewarm_i >= array_length(global.bg_prewarm_queue)) {
        global.bg_prewarm_done = true;

        if (surface_exists(global.bg_prewarm_surf)) surface_free(global.bg_prewarm_surf);
        global.bg_prewarm_surf = -1;
    }
}
