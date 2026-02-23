function scr_story_events_from_markers()
{
    global.story_events = [];
    global.camera_events = [];

    if (!is_array(global.markers) || array_length(global.markers) == 0) {
        if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
        scr_camera_events_from_markers();
        return;
    }

    for (var i = 0; i < array_length(global.markers); i++) {
        var m = global.markers[i];
        if (!is_struct(m)) continue;
        if (!variable_struct_exists(m, "type") || string(m.type) != "pause") continue;
        if (!variable_struct_exists(m, "t") || m.t <= 0.05) continue;

        var event_name = "";
        if (variable_struct_exists(m, "snd_name")) event_name = string(m.snd_name);

        var loop_val = variable_struct_exists(m, "loop") && (m.loop == true);
        if (!loop_val && event_name == "Pause_Loop") loop_val = true;

        array_push(global.story_events, {
            t: m.t,
            event_name: event_name,
            fade_out_ms: (variable_struct_exists(m, "fade_out_ms") ? m.fade_out_ms : 0),
            fade_in_ms: (variable_struct_exists(m, "fade_in_ms") ? m.fade_in_ms : 0),
            wait_confirm: (variable_struct_exists(m, "wait_confirm") && m.wait_confirm == true),
            loop: loop_val,
            caption: (variable_struct_exists(m, "caption") ? m.caption : ""),
            choices: (variable_struct_exists(m, "choices") ? m.choices : []),
            done: false
        });
    }

    array_sort(global.story_events, function(a,b){ return a.t - b.t; });
    if (script_exists(scr_difficulty_events_from_markers)) scr_difficulty_events_from_markers();
    scr_camera_events_from_markers();
}

function scr_camera_events_from_markers()
{
    global.camera_events = [];
}
