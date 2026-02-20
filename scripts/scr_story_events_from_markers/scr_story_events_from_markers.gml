function scr_story_events_from_markers()
{
    // Build global.story_events from marker data
    global.story_events = [];
    global.camera_events = [];

    // Hard rule: only markers explicitly placed by the editor become events
    if (!is_array(global.markers) || array_length(global.markers) == 0) {
        // Also rebuild marker-driven systems even if we have no story events
        if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
        scr_camera_events_from_markers();
        return;
    }

    for (var i = 0; i < array_length(global.markers); i++)
    {
        var m = global.markers[i];

        if (!is_struct(m)) continue;
        if (!variable_struct_exists(m, "type")) continue;
        if (!variable_struct_exists(m, "t")) continue;

        if (string(m.type) != "pause") continue;

        // Safety: never allow accidental start-trigger markers
        if (m.t <= 0.05) continue;

        // --- sound id ---
        var snd_id = -1;
        var snd_name = "";
        if (variable_struct_exists(m, "snd_name") && is_string(m.snd_name)) {
            snd_name = m.snd_name;
            snd_id = asset_get_index(snd_name); // returns -1 if not found
        }

        // --- safe defaults for fields that might not exist in older JSON ---
        var fade_out_ms  = (variable_struct_exists(m, "fade_out_ms")  ? m.fade_out_ms  : 0);
        var fade_in_ms   = (variable_struct_exists(m, "fade_in_ms")   ? m.fade_in_ms   : 0);
        var wait_confirm = (variable_struct_exists(m, "wait_confirm") ? (m.wait_confirm == true) : false);

        // LOOP: if marker has it, use it; otherwise default true for snd_pause
        var loop_val = false;
        if (variable_struct_exists(m, "loop")) loop_val = (m.loop == true);
        else if (snd_id == snd_pause || snd_name == "snd_pause") loop_val = true;

        var caption = (variable_struct_exists(m, "caption") ? m.caption : "");
        var choices = (variable_struct_exists(m, "choices") ? m.choices : []);

        array_push(global.story_events, {
            t: m.t,
            snd: snd_id,
            fade_out_ms:  fade_out_ms,
            fade_in_ms:   fade_in_ms,
            wait_confirm: wait_confirm,
            loop:         loop_val,

            caption: caption,
            choices: choices,

            done: false
        });
    }

    // Sort story events by time
    var n = array_length(global.story_events);
    for (var a = 0; a < n - 1; a++)
    {
        for (var b = a + 1; b < n; b++)
        {
            if (global.story_events[a].t > global.story_events[b].t)
            {
                var tmp = global.story_events[a];
                global.story_events[a] = global.story_events[b];
                global.story_events[b] = tmp;
            }
        }
    }

    // ALSO rebuild marker-driven systems (from the same global.markers list)
    if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
    scr_camera_events_from_markers();
}

function scr_camera_events_from_markers()
{
    global.camera_events = [];

    if (!is_array(global.markers) || array_length(global.markers) == 0) return;

    for (var i = 0; i < array_length(global.markers); i++)
    {
        var m = global.markers[i];
        if (!is_struct(m)) continue;
        if (!variable_struct_exists(m, "type") || string(m.type) != "camera") continue;
        if (!variable_struct_exists(m, "t")) continue;

        var ev_zoom = (variable_struct_exists(m, "zoom") ? real(m.zoom) : 1.0);
        if (!is_real(ev_zoom) || is_nan(ev_zoom)) ev_zoom = 1.0;

        var ev_pan_x = (variable_struct_exists(m, "pan_x") ? real(m.pan_x) : 0.0);
        if (!is_real(ev_pan_x) || is_nan(ev_pan_x)) ev_pan_x = 0.0;

        var ev_pan_y = (variable_struct_exists(m, "pan_y") ? real(m.pan_y) : 0.0);
        if (!is_real(ev_pan_y) || is_nan(ev_pan_y)) ev_pan_y = 0.0;

        var ev_ease = (variable_struct_exists(m, "ease") ? string_lower(string(m.ease)) : "smooth");
        if (ev_ease != "smooth" && ev_ease != "linear" && ev_ease != "hold") ev_ease = "smooth";

        array_push(global.camera_events, {
            t: max(0, m.t),
            zoom: clamp(ev_zoom, 0.35, 3.0),
            pan_x: clamp(ev_pan_x, -2500, 2500),
            pan_y: clamp(ev_pan_y, -1800, 1800),
            ease: ev_ease
        });
    }

    var n = array_length(global.camera_events);
    for (var a = 0; a < n - 1; a++)
    {
        for (var b = a + 1; b < n; b++)
        {
            if (global.camera_events[a].t > global.camera_events[b].t)
            {
                var tmp = global.camera_events[a];
                global.camera_events[a] = global.camera_events[b];
                global.camera_events[b] = tmp;
            }
        }
    }
}
