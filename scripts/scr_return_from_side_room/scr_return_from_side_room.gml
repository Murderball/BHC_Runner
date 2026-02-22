function scr_return_from_side_room()
{
    if (script_exists(scr_story_router_init)) scr_story_router_init();
    if (!variable_global_exists("STORY_RETURN") || !is_struct(global.STORY_RETURN) || !global.STORY_RETURN.pending)
    {
        show_debug_message("[story_router] no pending return snapshot");
        return false;
    }

    var _dest = global.STORY_RETURN.room;
    if (!room_exists(_dest))
    {
        show_debug_message("[story_router] invalid return room");
        return false;
    }

    if (is_string(global.STORY_RETURN.level_key) && global.STORY_RETURN.level_key != "")
        global.LEVEL_KEY = global.STORY_RETURN.level_key;

    if (is_string(global.STORY_RETURN.difficulty) && global.STORY_RETURN.difficulty != "")
    {
        global.DIFFICULTY = global.STORY_RETURN.difficulty;
        global.difficulty = global.STORY_RETURN.difficulty;
    }

    if (is_real(global.STORY_RETURN.chunk_slot)) global.chunk_slot = global.STORY_RETURN.chunk_slot;
    if (is_real(global.STORY_RETURN.chart_t))
    {
        global.START_AT_S = global.STORY_RETURN.chart_t;
        if (script_exists(scr_story_seek_time)) scr_story_seek_time(global.STORY_RETURN.chart_t);
    }

    global.STORY_RETURN.pending = false;
    scr_countdown_begin("return_from_side_room");
    room_goto(_dest);
    return true;
}
