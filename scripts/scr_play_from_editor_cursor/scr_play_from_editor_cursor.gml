function scr_play_from_editor_cursor() {
    // Ensure globals exist
    if (!variable_global_exists("WORLD_PPS")) scr_globals_init();

    // Seek + play song from editor cursor time
    // (If you have a dedicated editor cursor time var, swap it in here)
    var start_t = scr_chart_time(); // FIX: call the function
    if (start_t < 0) start_t = 0;

    // Snap camera immediately so the level matches the song start position
    var cam_target_x = start_t * global.WORLD_PPS;

    // If you have a camera instance, force its internal position too (prevents lerp “catch up”)
    var cam_inst = instance_find(obj_camera, 0);
    if (cam_inst != noone) {
        cam_inst.cam_world_x = cam_target_x;

        var cy = 0;
        if (variable_instance_exists(cam_inst, "cam_world_y")) cy = cam_inst.cam_world_y;

        camera_set_view_pos(view_camera[0], cam_target_x, cy);
    } else {
        camera_set_view_pos(view_camera[0], cam_target_x, 0);
    }

    // ---- ENTER PLAY MODE ----
    global.editor_on = false;

    // ------------------------------------------------------------
    // Pick the ACTIVE player instance (prefer global.player)
    // ------------------------------------------------------------
    var p = noone;

    if (variable_global_exists("player") && instance_exists(global.player)) {
        p = global.player;
    } else {
        // Fallback: grab whichever player exists in the room
        if (instance_exists(obj_player_guitar)) p = instance_find(obj_player_guitar, 0);
        else if (instance_exists(obj_player_guitar)) p = instance_find(obj_player_guitar, 0);
        else if (instance_exists(obj_player_bass)) p = instance_find(obj_player_bass, 0);
        else if (instance_exists(obj_player_drums)) p = instance_find(obj_player_drums, 0);
    }

    // ------------------------------------------------------------
    // Reset player state/position so it never stays under collision
    // ------------------------------------------------------------
    if (p != noone)
    {
        with (p)
        {
            // If your project uses global.player_world_y (recommended), prefer it.
            // Otherwise fall back to player_world_y if that exists.
            var target_y = y;

            if (variable_global_exists("player_world_y")) target_y = global.player_world_y;
            else if (variable_global_exists("player_world_y")) target_y = global.player_world_y; // safe duplicate, no harm
            else if (variable_global_exists("player_world_y")) target_y = global.player_world_y;

            // If you already have a variable called player_world_y (not global), use it:
            if (variable_global_exists("player_world_y")) target_y = global.player_world_y;
            else if (variable_global_exists("player_world_y")) target_y = global.player_world_y;

            // If your original variable is NOT global, but a plain variable player_world_y:
            if (variable_global_exists("player_world_y")) {
                // already handled above
            } else {
                // Try local (instance/global namespace)
                if (variable_global_exists("player_world_y")) target_y = global.player_world_y;
                // otherwise leave as current y
            }

            spawn_y = target_y;
            y = spawn_y;

            if (variable_instance_exists(id, "vsp")) vsp = 0;
            if (variable_instance_exists(id, "hsp")) hsp = 0;
            if (variable_instance_exists(id, "grounded")) grounded = false;

            // Reset attack locks/timers (only if they exist on this character)
            if (variable_instance_exists(id, "atk_state")) atk_state = 0;
            if (variable_instance_exists(id, "atk_timer")) atk_timer = 0;
            if (variable_instance_exists(id, "atk_cooldown")) atk_cooldown = 0;
            if (variable_instance_exists(id, "atk1_lock")) atk1_lock = false;
        }

        // Keep global.player in sync if it wasn't already
        global.player = p;
    }
}
