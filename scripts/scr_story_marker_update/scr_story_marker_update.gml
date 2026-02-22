function scr_story_marker_update(_marker_list)
{
    if (script_exists(scr_story_router_init)) scr_story_router_init();

    var _markers = is_array(_marker_list) ? _marker_list : (variable_global_exists("markers") ? global.markers : undefined);
    if (!is_array(_markers)) return;

    if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED) return;
    if (variable_global_exists("editor_on") && global.editor_on) return;
    if (variable_global_exists("COUNTDOWN_ACTIVE") && global.COUNTDOWN_ACTIVE) return;

    var _t = script_exists(scr_chart_time) ? scr_chart_time() : current_time / 1000;

    for (var i = 0; i < array_length(_markers); i++)
    {
        var m = _markers[i];
        if (!is_struct(m)) continue;
        if (!variable_struct_exists(m, "kind")) continue;

        var _kind = string(m.kind);

        if (_kind == "room_gate")
        {
            if (variable_struct_exists(m, "consumed") && m.consumed) continue;
            if (!variable_struct_exists(m, "t") || _t < real(m.t)) continue;
            if (!variable_struct_exists(m, "target")) continue;

            var _target_room = scr_story_room_id(m.target);
            if (_target_room < 0) continue;

            var _ctx_gate = {
                source: "room_gate",
                return_mode: variable_struct_exists(m, "return_mode") ? m.return_mode : "resume",
                return_chunk_slot: variable_struct_exists(m, "return_chunk_slot") ? m.return_chunk_slot : undefined,
                return_t: variable_struct_exists(m, "return_t") ? m.return_t : undefined,
                payload: variable_struct_exists(m, "payload") ? m.payload : undefined
            };

            var _ok_gate = scr_request_room_transition(m.target, _ctx_gate);

            var _one_shot = variable_struct_exists(m, "one_shot") ? m.one_shot : true;
            if (_ok_gate && _one_shot)
            {
                m.consumed = true;
                _markers[i] = m;
                if (!is_array(_marker_list) && variable_global_exists("markers")) global.markers[i] = m;
            }

            if (_ok_gate) break;
            continue;
        }

        if (_kind != "story_gate") continue;
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
            _markers[i] = m;
            if (!is_array(_marker_list) && variable_global_exists("markers")) global.markers[i] = m;
        }

        if (_ok) break;
    }
}
