function scr_story_marker_update(_marker_list)
{
    if (script_exists(scr_story_router_init)) scr_story_router_init();

    var _markers = is_array(_marker_list) ? _marker_list : (variable_global_exists("markers") ? global.markers : undefined);
    if (!is_array(_markers)) return;

    if (variable_global_exists("GAME_PAUSED") && global.GAME_PAUSED) return;
    if (variable_global_exists("editor_on") && global.editor_on) return;
    if (variable_global_exists("COUNTDOWN_ACTIVE") && global.COUNTDOWN_ACTIVE) return;

    var _t = script_exists(scr_chart_time) ? scr_chart_time() : current_time / 1000;
    var _prev_t = variable_global_exists("story_marker_prev_t") ? real(global.story_marker_prev_t) : _t;

    // Scrub/rewind safety: don't fire marker crossings when time jumps backwards.
    if (_t < _prev_t)
    {
        global.story_marker_prev_t = _t;
        return;
    }

    for (var i = 0; i < array_length(_markers); i++)
    {
        var m = _markers[i];
        if (!is_struct(m)) continue;

        var _kind = "";
        if (variable_struct_exists(m, "kind")) _kind = string(m.kind);
        else if (variable_struct_exists(m, "type")) _kind = string(m.type);
        if (_kind == "") continue;

        if (_kind == "room_gate")
        {
            if (variable_struct_exists(m, "consumed") && m.consumed) continue;
            if (!variable_struct_exists(m, "t") || !(_prev_t < real(m.t) && _t >= real(m.t))) continue;
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

        if (_kind == "room_goto")
        {
            if (variable_struct_exists(m, "consumed") && m.consumed) continue;
            if (!variable_struct_exists(m, "t")) continue;

            var _mt = real(m.t);
            if (!(_prev_t < _mt && _t >= _mt)) continue;

            var _side_idx = variable_struct_exists(m, "side_idx") ? floor(real(m.side_idx)) : 0;
            var _room_name = script_exists(scr_side_room_name_from_index)
                ? scr_side_room_name_from_index(_side_idx)
                : ("rm_side_" + string(_side_idx));

            var _room_asset = script_exists(scr_room_asset_from_name)
                ? scr_room_asset_from_name(_room_name)
                : asset_get_index(_room_name);

            if (_room_asset < 0)
            {
                show_debug_message("[room_goto] Missing room asset: " + _room_name);
                continue;
            }

            var _ok_goto = scr_request_room_transition(_room_name, {
                source: "room_goto",
                side_idx: _side_idx
            });

            var _one_shot_goto = variable_struct_exists(m, "one_shot") ? m.one_shot : true;
            if (_ok_goto && _one_shot_goto)
            {
                m.consumed = true;
                _markers[i] = m;
                if (!is_array(_marker_list) && variable_global_exists("markers")) global.markers[i] = m;
            }

            if (_ok_goto) break;
            continue;
        }

        if (_kind != "story_gate") continue;
        if (variable_struct_exists(m, "consumed") && m.consumed) continue;
        if (!variable_struct_exists(m, "t") || !(_prev_t < real(m.t) && _t >= real(m.t))) continue;

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

    global.story_marker_prev_t = _t;
}
