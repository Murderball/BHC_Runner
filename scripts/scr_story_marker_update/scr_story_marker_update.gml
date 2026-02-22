function scr_story_marker_update()
{
    if (script_exists(scr_story_router_init)) scr_story_router_init();
    if (!variable_global_exists("markers") || !is_array(global.markers)) return;
    if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED) return;
    if (variable_global_exists("editor_on") && global.editor_on) return;
    if (variable_global_exists("COUNTDOWN_ACTIVE") && global.COUNTDOWN_ACTIVE) return;

    var _t = script_exists(scr_chart_time) ? scr_chart_time() : current_time / 1000;

    for (var i = 0; i < array_length(global.markers); i++)
    {
        var m = global.markers[i];
        if (!is_struct(m)) continue;
        if (!variable_struct_exists(m, "kind") || string(m.kind) != "story_gate") continue;
        if (variable_struct_exists(m, "consumed") && m.consumed) continue;
        if (!variable_struct_exists(m, "t") || _t < real(m.t)) continue;

        var _ctx = {
            reason: "story_gate",
            marker_id: i,
            payload: variable_struct_exists(m, "payload") ? m.payload : {},
            return_mode: variable_struct_exists(m, "return_mode") ? m.return_mode : "resume"
        };

        var _ok = scr_request_room_transition(m.target, _ctx);

        if (_ok && (!variable_struct_exists(m, "one_shot") || m.one_shot))
        {
            m.consumed = true;
            global.markers[i] = m;
        }

        if (_ok) break;
    }
}
