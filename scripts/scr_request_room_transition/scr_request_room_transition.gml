function scr_request_room_transition(_target, _ctx)
{
    if (script_exists(scr_story_router_init)) scr_story_router_init();
    var _room_id = scr_story_room_id(_target);
    if (_room_id < 0)
    {
        show_debug_message("[story_router] transition failed; invalid target=" + string(_target));
        return false;
    }

    var _ctx_struct = is_struct(_ctx) ? _ctx : {};
    var _chart_t = script_exists(scr_chart_time) ? scr_chart_time() : current_time / 1000;
    var _chunk_slot = -1;
    if (variable_global_exists("chunk_slot")) _chunk_slot = global.chunk_slot;
    else if (variable_global_exists("active_chunk_slot")) _chunk_slot = global.active_chunk_slot;

    var _pstate = {};
    if (instance_exists(obj_player_drums))
    {
        var _p = instance_find(obj_player_drums, 0);
        if (variable_instance_exists(_p, "hp")) _pstate.hp = _p.hp;
        if (variable_instance_exists(_p, "state")) _pstate.state = _p.state;
    }

    global.STORY_RETURN = {
        room: room,
        level_key: variable_global_exists("LEVEL_KEY") ? string(global.LEVEL_KEY) : "",
        difficulty: variable_global_exists("DIFFICULTY") ? string(global.DIFFICULTY) : "",
        chunk_slot: _chunk_slot,
        chart_t: _chart_t,
        player_state: _pstate,
        from_marker_id: variable_struct_exists(_ctx_struct, "marker_id") ? _ctx_struct.marker_id : -1,
        pending: true
    };

    global.STORY_ENTRY_CONTEXT = _ctx_struct;

    global.STORY_ROUTER.transition_count += 1;
    global.STORY_ROUTER.last_from_room = room;
    global.STORY_ROUTER.last_to_room = _room_id;
    global.STORY_ROUTER.last_reason = variable_struct_exists(_ctx_struct, "reason") ? string(_ctx_struct.reason) : "story_gate";

    room_goto(_room_id);
    return true;
}
