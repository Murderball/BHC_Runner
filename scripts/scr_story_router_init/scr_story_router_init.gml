function scr_story_router_init()
{
    if (!variable_global_exists("STORY_ROUTER"))
    {
        global.STORY_ROUTER = {
            initialized: true,
            transition_count: 0,
            last_from_room: -1,
            last_to_room: -1,
            last_reason: ""
        };
    }

    if (!variable_global_exists("STORY_RETURN") || !is_struct(global.STORY_RETURN))
    {
        global.STORY_RETURN = {
            room: -1,
            level_key: "",
            difficulty: "",
            chunk_slot: -1,
            chart_t: 0,
            player_state: {},
            from_marker_id: -1,
            pending: false
        };
    }

    if (!variable_global_exists("STORY_ENTRY_CONTEXT") || !is_struct(global.STORY_ENTRY_CONTEXT))
        global.STORY_ENTRY_CONTEXT = {};

    if (!variable_global_exists("COUNTDOWN_ACTIVE")) global.COUNTDOWN_ACTIVE = false;
    if (!variable_global_exists("COUNTDOWN_REASON")) global.COUNTDOWN_REASON = "";
    if (!variable_global_exists("COUNTDOWN_LABEL")) global.COUNTDOWN_LABEL = "";
    if (!variable_global_exists("COUNTDOWN_TIMER_S")) global.COUNTDOWN_TIMER_S = 0;
    if (!variable_global_exists("COUNTDOWN_TOTAL_S")) global.COUNTDOWN_TOTAL_S = 0;

    if (!variable_global_exists("DEBUG_KEYBINDS"))
    {
        global.DEBUG_KEYBINDS = debug_mode;
    }

    if (!instance_exists(obj_countdown_controller))
    {
        var _layer = "Instances";
        if (!layer_exists(_layer))
        {
            var _lid = layer_get_id_at_depth(0);
            if (_lid != -1) _layer = layer_get_name(_lid);
        }

        if (_layer != "" && layer_exists(_layer))
            instance_create_layer(0, 0, _layer, obj_countdown_controller);
    }
}
