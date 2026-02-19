/// scr_editor_enter_reset()
/// Called once when editor mode turns ON.
/// Resets time/camera/chunks WITHOUT forcing difficulty/song to normal.

function scr_editor_enter_reset()
{
    // Keep whatever difficulty you're currently in (don't force "normal")
    // Also: do NOT swap audio when entering editor (prevents normal song selection)
    var d = "normal";
    if (variable_global_exists("difficulty")) d = string_lower(string(global.difficulty));
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    if (script_exists(scr_apply_difficulty))
    {
        // Visuals can stay consistent with current diff, but don't touch audio
        scr_apply_difficulty(d, "enter_editor", true, false);
    }
    else
    {
        global.difficulty = d;
        global.DIFFICULTY = d;
        // (No audio changes here)
    }

    // Reset editor/song time start (PLAYSTART)
    if (variable_global_exists("START_AT_S")) global.START_AT_S = 0;

    // If you use offsets anywhere, zero them
    if (variable_global_exists("song_time_offset"))  global.song_time_offset  = 0;
    if (variable_global_exists("chart_time_offset")) global.chart_time_offset = 0;

    // Snap camera to start immediately
    if (instance_exists(obj_camera))
    {
        var cam = view_camera[0];

        // If your camera script uses instance vars, reset them too
        var cam_inst = instance_find(obj_camera, 0);
        if (cam_inst != noone)
        {
            if (variable_instance_exists(cam_inst, "cam_world_x")) cam_inst.cam_world_x = 0;
            if (variable_instance_exists(cam_inst, "cam_world_y")) cam_inst.cam_world_y = 0;
        }

        camera_set_view_pos(cam, 0, 0);
    }

    // Force chunk strip to restamp from the beginning (cheap)
    if (instance_exists(obj_chunk_manager))
    {
        with (obj_chunk_manager)
        {
            if (is_array(slot_ci)) {
                for (var i = 0; i < array_length(slot_ci); i++) slot_ci[i] = -1;
            }
        }
    }

    show_debug_message("[Editor] reset to start (kept difficulty=" + d + ", no audio swap)");
}
